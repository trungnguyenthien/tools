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
        <link rel="preconnect" href="https://fonts.googleapis.com">
        <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
        <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;500;600;700;800&family=JetBrains+Mono:wght@400;500&display=swap" rel="stylesheet">
        <style>
          :root {
            --bg: #090d16;
            --card-bg: rgba(17, 24, 39, 0.45);
            --border-color: rgba(255, 255, 255, 0.08);
            --border-hover: rgba(255, 255, 255, 0.18);
            --text-primary: #f1f5f9;
            --text-secondary: #94a3b8;
            --accent-blue: #38bdf8;
            --accent-green: #10b981;
            --accent-purple: #818cf8;
            --glow-blue: rgba(56, 189, 248, 0.15);
            --font-display: 'Outfit', sans-serif;
            --font-mono: 'JetBrains Mono', monospace;
          }

          * {
            box-sizing: border-box;
            margin: 0;
            padding: 0;
          }

          body {
            background-color: var(--bg);
            background-image: 
              radial-gradient(at 0% 0%, rgba(56, 189, 248, 0.08) 0px, transparent 50%),
              radial-gradient(at 100% 100%, rgba(129, 140, 248, 0.08) 0px, transparent 50%),
              radial-gradient(at 50% 50%, rgba(16, 185, 129, 0.03) 0px, transparent 50%);
            background-attachment: fixed;
            color: var(--text-primary);
            font-family: var(--font-display);
            line-height: 1.6;
            min-height: 100vh;
            display: flex;
            flex-direction: column;
          }

          .container {
            max-width: 900px;
            margin: 0 auto;
            padding: 4rem 2rem;
            width: 100%;
            flex: 1;
          }

          /* General Markdown Styling */
          .markdown-body {
            background: var(--card-bg);
            border: 1px solid var(--border-color);
            border-radius: 24px;
            padding: 3.5rem;
            backdrop-filter: blur(12px);
            box-shadow: 0 20px 50px rgba(0, 0, 0, 0.3);
          }

          @media (max-width: 768px) {
            .container {
              padding: 2rem 1rem;
            }
            .markdown-body {
              padding: 2rem 1.5rem;
            }
          }

          .markdown-body h1 {
            font-size: 2.6rem;
            font-weight: 800;
            margin-bottom: 2rem;
            background: linear-gradient(135deg, #f1f5f9 20%, #94a3b8 50%, #38bdf8 100%);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            border-bottom: 1px solid rgba(255, 255, 255, 0.08);
            padding-bottom: 1rem;
            line-height: 1.25;
          }

          .markdown-body h2 {
            font-size: 1.8rem;
            font-weight: 700;
            margin-top: 2.5rem;
            margin-bottom: 1.2rem;
            color: #f1f5f9;
            border-bottom: 1px solid rgba(255, 255, 255, 0.08);
            padding-bottom: 0.5rem;
          }

          .markdown-body h3 {
            font-size: 1.4rem;
            font-weight: 600;
            margin-top: 2rem;
            margin-bottom: 1rem;
            color: #e2e8f0;
          }

          .markdown-body p {
            font-size: 1.1rem;
            color: var(--text-secondary);
            margin-bottom: 1.5rem;
            line-height: 1.7;
          }

          .markdown-body a {
            color: var(--accent-blue);
            text-decoration: none;
            border-bottom: 1px dashed rgba(56, 189, 248, 0.4);
            transition: all 0.2s;
            font-weight: 500;
          }

          .markdown-body a:hover {
            color: #56caff;
            border-bottom: 1px solid var(--accent-blue);
          }

          .markdown-body ul, .markdown-body ol {
            margin-left: 1.5rem;
            margin-bottom: 1.5rem;
            color: var(--text-secondary);
          }

          .markdown-body li {
            margin-bottom: 0.6rem;
            font-size: 1.05rem;
            line-height: 1.6;
          }

          .markdown-body li strong {
            color: var(--text-primary);
          }

          .markdown-body ul ul, .markdown-body ol ol, 
          .markdown-body ul ol, .markdown-body ol ul {
            margin-top: 0.5rem;
            margin-bottom: 0.5rem;
            border-left: 1px solid rgba(255, 255, 255, 0.08);
            padding-left: 1rem;
            list-style-type: circle;
          }

          .markdown-body hr {
            border: none;
            border-top: 1px solid rgba(255, 255, 255, 0.08);
            margin: 3.5rem 0;
          }

          .markdown-body blockquote {
            background: rgba(56, 189, 248, 0.04);
            border-left: 4px solid var(--accent-blue);
            border-radius: 0 12px 12px 0;
            padding: 1.25rem 1.5rem;
            margin-bottom: 1.5rem;
            color: #e2e8f0;
          }

          .markdown-body blockquote p {
            margin-bottom: 0;
            color: #cbd5e1;
            font-size: 1.05rem;
          }

          .markdown-body pre {
            background: rgba(15, 23, 42, 0.6);
            border: 1px solid rgba(255, 255, 255, 0.06);
            border-radius: 12px;
            padding: 1.25rem;
            overflow-x: auto;
            margin-bottom: 1.5rem;
          }

          .markdown-body code {
            font-family: var(--font-mono);
            font-size: 0.9rem;
            color: #e2e8f0;
          }

          .markdown-body :not(pre) > code {
            background: rgba(255, 255, 255, 0.08);
            padding: 0.15rem 0.4rem;
            border-radius: 4px;
            font-size: 0.85em;
            border: 1px solid rgba(255, 255, 255, 0.04);
          }

          footer {
            text-align: center;
            padding: 3rem 2rem;
            font-size: 0.95rem;
            color: var(--text-secondary);
            border-top: 1px solid var(--border-color);
            background: rgba(2, 6, 23, 0.4);
            backdrop-filter: blur(12px);
            width: 100%;
            margin-top: auto;
          }

          footer a {
            color: var(--text-primary);
            text-decoration: none;
            transition: color 0.2s;
          }

          footer a:hover {
            color: var(--accent-blue);
          }
        </style>
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
