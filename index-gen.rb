require 'cgi'

class GenScript
  def self.parse_inline(text)
    # Convert bold **text**
    t = text.dup
    t.gsub!(/\*\*(.*?)\*\*/, '<strong>\1</strong>')
    # Convert italic *text*
    t.gsub!(/\*(.*?)\*/, '<em>\1</em>')
    # Convert inline code `code`
    t.gsub!(/`(.*?)`/, '<code>\1</code>')
    # Convert links [text](url)
    t.gsub!(/\[(.*?)\]\((.*?)\)/, '<a href="\2" class="tool-link">\1 <span class="arrow">→</span></a>')
    t
  end

  def self.generate(md_content)
    lines = md_content.split("\n")
    
    html = []
    
    # State tracking
    current_section = :hero
    in_list = false
    in_sub_list = false
    
    html << '<div class="container">'
    html << '  <header class="hero">'
    
    lines.each do |line|
      stripped = line.strip
      
      # Handle horizontal rules
      if stripped == '---'
        # Close lists if open
        if in_sub_list; html << '      </ul>'; in_sub_list = false; end
        if in_list; html << '    </ul>'; in_list = false; end
        
        # Transition section based on where we are
        if current_section == :hero
          html << '  </header>'
          html << '  <section class="privacy-section">'
          current_section = :privacy
        elsif current_section == :privacy
          html << '  </section>'
          html << '  <section class="tools-section">'
          html << '    <h2>📌 Danh sách công cụ</h2>'
          html << '    <div class="tools-grid">'
          current_section = :tools_grid_open
        elsif current_section == :tool_card
          html << '    </div> <!-- /tool-card -->'
          current_section = :tools_grid_open
        end
        next
      end
      
      # Handle blank lines
      if stripped.empty?
        next
      end
      
      # Handle Headings
      if stripped.start_with?('# ')
        title = stripped[2..-1]
        html << "    <h1>#{parse_inline(title)}</h1>"
      elsif stripped.start_with?('## ')
        heading_text = stripped[3..-1]
        if heading_text.include?('🔒 Cam kết')
          html << "    <h2 class=\"privacy-title\">#{parse_inline(heading_text)}</h2>"
        elsif heading_text.include?('📌 Danh sách')
          # Already structured as section title, skip duplicate h2
        elsif heading_text.include?('🚀 Cách sử dụng')
          # Close previous sections
          if in_sub_list; html << '      </ul>'; in_sub_list = false; end
          if in_list; html << '    </ul>'; in_list = false; end
          if current_section == :tool_card
            html << '    </div> <!-- /tool-card -->'
            html << '    </div> <!-- /tools-grid -->'
            html << '  </section>'
          elsif current_section == :tools_grid_open
            html << '    </div> <!-- /tools-grid -->'
            html << '  </section>'
          end
          html << '  <section class="usage-section">'
          html << "    <h2>🚀 #{parse_inline(heading_text.sub('🚀', '').strip)}</h2>"
          current_section = :usage
        else
          html << "    <h2>#{parse_inline(heading_text)}</h2>"
        end
      elsif stripped.start_with?('### ')
        # Close previous list if any
        if in_sub_list; html << '      </ul>'; in_sub_list = false; end
        if in_list; html << '    </ul>'; in_list = false; end
        
        # This is a tool! Let's close previous tool card if open
        if current_section == :tool_card
          html << '    </div> <!-- /tool-card -->'
        end
        
        tool_title = stripped[4..-1]
        # Remove numbers like "1. " or "2. " from the start of the title
        clean_title = tool_title.sub(/^\d+\.\s+/, '')
        
        html << '    <div class="tool-card">'
        html << "      <h3 class=\"tool-card-title\">#{parse_inline(clean_title)}</h3>"
        current_section = :tool_card
      # Handle lists
      elsif stripped.start_with?('- ') || stripped.start_with?('* ')
        # Sub-list check (indented by 2 or more spaces in original line)
        is_sub = line.start_with?('  ') || line.start_with?("\t")
        
        content = stripped[2..-1]
        parsed_content = parse_inline(content)
        
        if is_sub
          unless in_sub_list
            html << '      <ul class="sub-list">'
            in_sub_list = true
          end
          html << "        <li>#{parsed_content}</li>"
        else
          if in_sub_list
            html << '      </ul>'
            in_sub_list = false
          end
          unless in_list
            html << '    <ul class="feature-list">'
            in_list = true
          end
          html << "      <li>#{parsed_content}</li>"
        end
      elsif stripped =~ /^\d+\.\s+(.*)/
        # Numbered list for usage
        content = stripped.sub(/^\d+\.\s+/, '')
        unless in_list
          html << '    <ol class="usage-list">'
          in_list = true
        end
        html << "      <li>#{parse_inline(content)}</li>"
      else
        # Normal paragraph or italic intro
        if stripped.start_with?('*') && stripped.end_with?('*')
          # Italic subtitle/tagline for tool
          text = stripped[1..-2]
          html << "      <p class=\"tool-tagline\">#{parse_inline(text)}</p>"
        else
          html << "    <p>#{parse_inline(stripped)}</p>"
        end
      end
    end
    
    # Close any open elements at the end
    if in_sub_list; html << '      </ul>'; end
    if in_list
      if current_section == :usage
        html << '    </ol>'
      else
        html << '    </ul>'
      end
    end
    if current_section == :tool_card
      html << '    </div> <!-- /tool-card -->'
      html << '    </div> <!-- /tools-grid -->'
      html << '  </section>'
    elsif current_section == :tools_grid_open
      html << '    </div> <!-- /tools-grid -->'
      html << '  </section>'
    elsif current_section == :usage
      html << '  </section>'
    end
    
    html << '</div> <!-- /container -->'
    html.join("\n")
  end
end

if __FILE__ == $0
  begin
    unless File.exist?("README.MD")
      puts "❌ Không tìm thấy file README.MD trong thư mục hiện tại."
      exit 1
    end

    md_content = File.read("README.MD")
    html_body = GenScript.generate(md_content)
    
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
            --glow-green: rgba(16, 185, 129, 0.12);
            --glow-purple: rgba(129, 140, 248, 0.15);
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
            max-width: 1040px;
            margin: 0 auto;
            padding: 4rem 2rem;
            width: 100%;
            flex: 1;
          }

          header.hero {
            text-align: center;
            margin-bottom: 4rem;
            position: relative;
          }

          header.hero h1 {
            font-size: 3rem;
            font-weight: 800;
            letter-spacing: -0.03em;
            line-height: 1.2;
            background: linear-gradient(135deg, #f1f5f9 20%, #94a3b8 50%, #38bdf8 100%);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            margin-bottom: 1.5rem;
            display: inline-block;
          }

          header.hero p {
            font-size: 1.2rem;
            color: var(--text-secondary);
            max-width: 680px;
            margin: 0 auto;
            font-weight: 400;
          }

          /* Privacy Card styling */
          .privacy-section {
            background: rgba(16, 185, 129, 0.04);
            border: 1px solid rgba(16, 185, 129, 0.15);
            border-radius: 20px;
            padding: 2.5rem;
            margin-bottom: 4rem;
            backdrop-filter: blur(12px);
            box-shadow: 0 10px 30px -10px var(--glow-green);
            position: relative;
            overflow: hidden;
          }

          .privacy-section::before {
            content: '';
            position: absolute;
            top: -50%;
            right: -50%;
            width: 100%;
            height: 100%;
            background: radial-gradient(circle, rgba(16, 185, 129, 0.05) 0%, transparent 70%);
            pointer-events: none;
          }

          .privacy-title {
            font-size: 1.5rem;
            font-weight: 700;
            color: #34d399;
            margin-bottom: 1.5rem;
            display: flex;
            align-items: center;
            gap: 0.75rem;
            border: none;
            padding-bottom: 0;
          }

          .privacy-section ul.feature-list {
            list-style: none;
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: 1.5rem;
          }

          .privacy-section ul.feature-list > li {
            position: relative;
            padding-left: 2rem;
            font-size: 1.05rem;
            color: var(--text-primary);
          }

          .privacy-section ul.feature-list > li::before {
            content: '✓';
            position: absolute;
            left: 0;
            color: #34d399;
            font-weight: 900;
            font-size: 1.2rem;
            line-height: 1.2;
          }

          .privacy-section ul.feature-list > li strong {
            color: #34d399;
            display: block;
            margin-bottom: 0.25rem;
          }

          /* Tools Section */
          .tools-section h2 {
            font-size: 2rem;
            font-weight: 700;
            margin-bottom: 2rem;
            display: flex;
            align-items: center;
            gap: 0.75rem;
          }

          .tools-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(420px, 1fr));
            gap: 2rem;
            margin-bottom: 4rem;
          }

          @media (max-width: 768px) {
            .tools-grid {
              grid-template-columns: 1fr;
            }
            header.hero h1 {
              font-size: 2.2rem;
            }
          }

          .tool-card {
            background: var(--card-bg);
            border: 1px solid var(--border-color);
            border-radius: 20px;
            padding: 2.5rem;
            backdrop-filter: blur(12px);
            transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
            display: flex;
            flex-direction: column;
            position: relative;
            overflow: hidden;
            box-shadow: 0 4px 30px rgba(0, 0, 0, 0.2);
          }

          .tool-card::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: linear-gradient(135deg, rgba(56, 189, 248, 0.03) 0%, transparent 60%);
            pointer-events: none;
            transition: opacity 0.3s;
            opacity: 0.5;
          }

          .tool-card:hover {
            transform: translateY(-6px);
            border-color: var(--border-hover);
            box-shadow: 
              0 20px 40px -15px rgba(0, 0, 0, 0.4),
              0 0 40px -10px var(--glow-blue);
          }

          .tool-card:hover::before {
            opacity: 1;
          }

          .tool-card-title {
            font-size: 1.6rem;
            font-weight: 700;
            margin-bottom: 0.75rem;
            display: flex;
            align-items: center;
            gap: 0.5rem;
          }

          .tool-card-title a {
            color: var(--text-primary);
            text-decoration: none;
            transition: color 0.2s;
            display: flex;
            align-items: center;
            gap: 0.5rem;
          }

          .tool-card-title a:hover {
            color: var(--accent-blue);
          }

          .tool-card-title a .arrow {
            font-size: 1.2rem;
            transition: transform 0.2s;
            display: inline-block;
          }

          .tool-card:hover .tool-card-title a .arrow {
            transform: translateX(4px);
          }

          .tool-tagline {
            font-size: 1.05rem;
            font-style: italic;
            color: var(--text-secondary);
            margin-bottom: 2rem;
            line-height: 1.5;
          }

          /* Inner lists in cards */
          .tool-card ul.feature-list {
            list-style: none;
            margin-top: auto;
          }

          .tool-card ul.feature-list > li {
            font-size: 1rem;
            color: var(--text-primary);
            line-height: 1.5;
            margin-bottom: 1.5rem;
          }

          .tool-card ul.feature-list > li:last-child {
            margin-bottom: 0;
          }

          .tool-card ul.feature-list > li > strong {
            color: var(--accent-blue);
            display: block;
            font-size: 1rem;
            margin-bottom: 0.5rem;
            font-weight: 600;
          }

          .tool-card ul.sub-list {
            list-style: none;
            margin-top: 0.75rem;
            padding-left: 1rem;
            border-left: 1px solid rgba(255, 255, 255, 0.08);
            display: flex;
            flex-direction: column;
            gap: 0.5rem;
          }

          .tool-card ul.sub-list > li {
            font-size: 0.95rem;
            color: var(--text-secondary);
            position: relative;
            padding-left: 1.25rem;
          }

          .tool-card ul.sub-list > li::before {
            content: '•';
            position: absolute;
            left: 0;
            color: rgba(255, 255, 255, 0.3);
          }

          .tool-card ul.sub-list > li strong {
            color: var(--text-primary);
            font-weight: 500;
          }
          
          code {
            font-family: var(--font-mono);
            background: rgba(255, 255, 255, 0.08);
            padding: 0.15rem 0.4rem;
            border-radius: 4px;
            font-size: 0.88em;
            color: #e2e8f0;
            border: 1px solid rgba(255, 255, 255, 0.04);
          }

          /* Usage Guide */
          .usage-section {
            background: var(--card-bg);
            border: 1px solid var(--border-color);
            border-radius: 20px;
            padding: 2.5rem;
            backdrop-filter: blur(12px);
            margin-bottom: 2rem;
          }

          .usage-section h2 {
            font-size: 1.8rem;
            font-weight: 700;
            margin-bottom: 1.75rem;
            display: flex;
            align-items: center;
            gap: 0.75rem;
          }

          .usage-list {
            list-style: none;
            display: flex;
            flex-direction: column;
            gap: 1.5rem;
          }

          .usage-list > li {
            position: relative;
            padding-left: 3rem;
            font-size: 1.05rem;
            color: var(--text-primary);
          }

          .usage-list > li::before {
            counter-increment: step-counter;
            content: counter(step-counter);
            position: absolute;
            left: 0;
            top: 50%;
            transform: translateY(-50%);
            width: 2.2rem;
            height: 2.2rem;
            background: linear-gradient(135deg, var(--accent-blue), var(--accent-purple));
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 0.95rem;
            font-weight: 700;
            color: #020617;
          }

          body {
            counter-reset: step-counter;
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
        [HTML_CONTENT]
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
