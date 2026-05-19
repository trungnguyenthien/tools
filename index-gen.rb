require 'cgi'

class MarkdownParser
  def self.to_html(markdown)
    html = []
    lines = markdown.split("\n")
    
    in_code_block = false
    list_stack = [] # stack of hashes: { type: :ul/:ol, indent: Integer }
    
    lines.each do |line|
      # 1. Handle Code Blocks
      if line =~ /^```(\w*)/
        if in_code_block
          html << "</code></pre>"
          in_code_block = false
        else
          lang = $1
          html << "<pre><code class=\"language-#{lang}\">"
          in_code_block = true
        end
        next
      end
      
      if in_code_block
        html << CGI.escapeHTML(line)
        next
      end
      
      stripped = line.strip
      
      # Close lists if blank line
      if stripped.empty?
        while !list_stack.empty?
          html << (list_stack.pop[:type] == :ul ? "</ul>" : "</ol>")
        end
        next
      end
      
      # Horizontal Rule
      if stripped == '---' || stripped == '***' || stripped == '___'
        while !list_stack.empty?
          html << (list_stack.pop[:type] == :ul ? "</ul>" : "</ol>")
        end
        html << "<hr />"
        next
      end
      
      # Headings (h1 to h6)
      if stripped =~ /^(\#+)\s+(.*)/
        while !list_stack.empty?
          html << (list_stack.pop[:type] == :ul ? "</ul>" : "</ol>")
        end
        level = $1.length
        content = parse_inline($2)
        html << "<h#{level}>#{content}</h#{level}>"
        next
      end
      
      # Blockquotes
      if stripped =~ /^>\s?(.*)/
        while !list_stack.empty?
          html << (list_stack.pop[:type] == :ul ? "</ul>" : "</ol>")
        end
        content = $1
        html << "<blockquote>#{parse_inline(content)}</blockquote>"
        next
      end
      
      # Lists (Unordered & Ordered)
      leading_spaces = line.match(/^(\s*)/)[1].length
      is_ul = stripped.start_with?('- ') || stripped.start_with?('* ') || stripped.start_with?('+ ')
      is_ol = stripped =~ /^\d+\.\s(.*)/
      
      if is_ul || is_ol
        type = is_ul ? :ul : :ol
        content = is_ul ? stripped[2..-1] : stripped.sub(/^\d+\.\s/, '')
        
        if list_stack.empty?
          list_stack << { type: type, indent: leading_spaces }
          html << (type == :ul ? "<ul>" : "<ol>")
        elsif leading_spaces > list_stack.last[:indent]
          list_stack << { type: type, indent: leading_spaces }
          html << (type == :ul ? "<ul>" : "<ol>")
        elsif leading_spaces < list_stack.last[:indent]
          while !list_stack.empty? && leading_spaces < list_stack.last[:indent]
            html << (list_stack.pop[:type] == :ul ? "</ul>" : "</ol>")
          end
          
          if !list_stack.empty? && list_stack.last[:indent] == leading_spaces && list_stack.last[:type] != type
            html << (list_stack.pop[:type] == :ul ? "</ul>" : "</ol>")
            list_stack << { type: type, indent: leading_spaces }
            html << (type == :ul ? "<ul>" : "<ol>")
          elsif list_stack.empty?
            list_stack << { type: type, indent: leading_spaces }
            html << (type == :ul ? "<ul>" : "<ol>")
          end
        elsif list_stack.last[:type] != type
          html << (list_stack.pop[:type] == :ul ? "</ul>" : "</ol>")
          list_stack << { type: type, indent: leading_spaces }
          html << (type == :ul ? "<ul>" : "<ol>")
        end
        
        html << "<li>#{parse_inline(content)}</li>"
        next
      end
      
      # Paragraph
      while !list_stack.empty?
        html << (list_stack.pop[:type] == :ul ? "</ul>" : "</ol>")
      end
      html << "<p>#{parse_inline(stripped)}</p>"
    end
    
    while !list_stack.empty?
      html << (list_stack.pop[:type] == :ul ? "</ul>" : "</ol>")
    end
    
    html.join("\n")
  end
  
  def self.parse_inline(text)
    t = text.dup
    # Convert bold **text**
    t.gsub!(/\*\*(.*?)\*\*/, '<strong>\1</strong>')
    # Convert italic *text*
    t.gsub!(/\*(.*?)\*/, '<em>\1</em>')
    # Convert inline code `code`
    t.gsub!(/`(.*?)`/, '<code>\1</code>')
    # Convert links [text](url)
    t.gsub!(/\[(.*?)\]\((.*?)\)/, '<a href="\2">\1</a>')
    t
  end
end

if __FILE__ == $0
  begin
    unless File.exist?("README.MD")
      puts "❌ Không tìm thấy file README.MD trong thư mục hiện tại."
      exit 1
    end

    md_content = File.read("README.MD")
    html_body = MarkdownParser.to_html(md_content)
    
    template = <<~HTML
      <!DOCTYPE html>
      <html lang="vi">
      <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Bộ Công Cụ Tiện Ích Trình Duyệt</title>
        <link rel="stylesheet" href="./global.css?v=1.1">
      </head>
      <body>
        <div class="container">
          <article class="markdown-body">
            [HTML_CONTENT]
          </article>
        </div>
        <footer>
          <p>⚡ 100% Client-side • Bảo mật & Riêng tư hoàn hảo</p>
          <p style="margin-top: 0.5rem; font-size: 0.85rem; opacity: 0.7;">
            Mã nguồn dự án trên <a href="https://github.com/trungnguyen/tools" target="_blank" rel="noopener noreferrer">GitHub</a>
          </p>
        </footer>
      </body>
      </html>
    HTML
    
    final_html = template.gsub('[HTML_CONTENT]', html_body)
    
    File.write("index.html", final_html)
    puts "✅ Đã tạo thành công file index.html từ README.MD!"
  rescue => e
    puts "❌ Đã có lỗi xảy ra: #{e.message}"
    puts e.backtrace.join("\n")
  end
end
