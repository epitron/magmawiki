require 'erb'

module Parser
  class MediaWiki
    def parse(text)
      text = ERB::Util::html_escape(text)
      
      text.gsub!(/&ndash;/,'-')
			text.gsub!(/&quot;/, '"')
      
      text.gsub!(/\&amp;(nbsp);/, '&\1')
      
      text = convert_tables(text)
      text = convert_html(text)

			text
    end
    
  private
		def convert_html(text)
			
			#please fix line breaks

			#bold
			text.gsub!(/\'\'\'([^\n\']+)\'\'\'/,'<strong>\\1</strong>')

			#italics
			text.gsub!(/\'\'([^\'\n]+)\'\'?/,'<em>\\1</em>')
			
			#interwiki links
			#text.gsub(/\[\[(.*?)(\|.*?)?\]\]/)  { |match| wikilink_helper($1, $2) }

			text.gsub!(/\[\[([^\|\n\]]+)([\|]([^\]]+))?\]\]/) { |match| internalwiki_helper($1, $3) }
			#text.gsub!(/\[\[([^\|\n\]:]+)\]\]/) { |match| internalwiki_helper($1, $2) }

			#text.gsub!(/\[([^\[\]\|\n\': ]+)\]/) { |match| externallink_helper($1, $2) }
			#text.gsub!(/\[([^\[\]\|\n\' ]+)[\| ]([^\]\']+)\]/) { |match| externallink_helper($1, $2) }

			#text.gsub!(/\{\{([^\|\n\}]+)([\|]?([^\}]+))+\}\}/,'Interwiki: \\1 &raquo; \\3')
			
			#text.gsub!(/\[\[([^\|\n\]]{2})([\:]([^\]]+))?\]\]/,'Translation: \\1 &raquo; \\3')
			#text.gsub!(/\[\[([^\|\n\]]+)([\:]([^\]]+))?\]\]/,'Category: \\1 - \\3')
			#image
			#text.gsub!(/\[\[([^\|\n\]]+)([\|]([^\]]+))+\]\]/,'Image: \\0+\\1+\\2+\\3')


			text.gsub!(/&lt;(\/?)(small|sup|sub|u)&gt;/,'<\\1\\2>')

			#text.gsub!(/\n*&lt;br *\/?&gt;\n*/,"\n")
			text.gsub!(/&lt;(\/?)(math|pre|code|nowiki)&gt;/,'<\\1pre>')
			text.gsub!(/&lt;!--/,'<!--')
			text.gsub!(/--&gt;/,' -->')

			6.downto 1 do |n|
				text.gsub!(/(^|\s)[=]{#{n}}(.+)[=]{#{n}}\s/, "<h#{n}>\\2</h#{n}>")
			end

			#text.gsub!(/(\n[ ]*[^#* ][^\n]*)\n(([ ]*[*]([^\n]*)\n)+)/,'\\1<ul>'+"\n"+'\\2'+'</ul>'+"\n")
			#text.gsub!(/(\n[ ]*[^#* ][^\n]*)\n(([ ]*[#]([^\n]*)\n)+)/,'\\1<ol>'+"\n"+'\\2'+'</ol>'+"\n")

			#text.gsub!(/\n[ ]*[\*#]+([^\n]*)/,'<li>\\1</li>')
			text.gsub!(/----/,'<hr />')

			#text.gsub!(/[>]<br\/>[<]/,"><")

			text
		end

		def externallink_helper(match, match2)
			target = match
			text = match2.nil? ? match : match2
			
			return '<a href=#'+ target + ">" + text + '</a>'
		end

		def wikilink_helper(match, match2)
			target = match
			text = match2.nil? ? match : match2
			
			return '<a href=#'+ target + ">" + text + '</a>'
		end

		def internalwiki_helper(match , match2)
			target = match
			text = match2.nil? ? match : match2
			cls = "class=\"dunno\" ";
			
			return '<a ' + cls + " href=#" + target + ">" + text + '</a>'
		end

    def convert_tables(text)
      lines = text.split("\n")
      
      inner_table = 0
      inner_table_data = []
      
      lines.each do |line|
        inner_table = (inner_table + 1) if line[0,2] == '{|'
				inner_table_data[inner_table] = "" if inner_table_data[inner_table].nil?
        inner_table_data[inner_table] << line + "\n"
        if inner_table > 0
          if line[0,2] == '|}'
            inner_table_converted = convert_individual_table(inner_table_data[inner_table])
            inner_table_data[inner_table] = ""
            inner_table = inner_table - 1
            inner_table_data[inner_table] << inner_table_converted + "\n"
          end
        end
      end
      
      return inner_table_data[0]
    end
    
    def convert_individual_table(text)
      lines = text.split("\n")
      in_table = false;
      
      lines.each do |line|
        line.strip!
        if line[0,1] == '{'
          internals = line[1, line.length].split('| ', 2)
          table_open = true
          table = "<table " + internals[0] + ">\n"
        elsif line[0,1] == "|"
          line['|'] = ""
          if line[0,5] == '-----'
            table << "</th>\n"    if th_open
            table << "</td>\n"    if td_open
            table << "\t</tr>\n"  if row_open
            table << "\t<tr>\n"
            row_open = true
            td_open = false
            th_open = false
          elsif line[0,1] == '}'
            break
          else
            internals = line.split('| ', 2)
            table << "</td>\n" if td_open
            if internals.size == 1
              table << "\t\t<td>" + simpleText(internals[0])
            else
              table << "\t\t<td " + internals[0] + ">" + simpleText(internals[1])
            end
						td_open = true
					end
				elsif line[0,1] == "!"
					internals = line[1, line.length-1].spit('| ', 2)
					table << "</td>\d" if th_open
					if internals.size == 1
						table << "\t\t<th>" + simpleText(internals[0])
					else
						table << "\t\t<th " + internals[0] + ">" + simpleText(internals[1])
					end
					th_open = true
				else
					table << simpleText(line) + "\n"
				end
			end
			table << "</th>\n" if th_open
			table << "</td>\n" if td_open
			table << "\t</tr>\n" if row_open
			table << "</table>\n" if table_open

			return table
    end
  end
end
