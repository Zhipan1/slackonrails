module EmojiHelper
  def emojify(content, size=20)
    h(content).to_str.gsub(/:([\w+-]+):/) do |match|
      if emoji = Emoji.find_by_alias($1)
        %(<img alt="#$1" src="#{image_path("emoji/#{emoji.image_filename}")}" style="vertical-align:sub" width="#{size}" height="#{size}" />)
      else
        match
      end
    end.html_safe if content.present?
  end

  def emoji_shorthand(content)
    replace = [[':)', ':blush:'], [':D', ':smile:']]
    replace.each do |syntax|
      content = content.gsub syntax[0], syntax[1]
    end
    content
  end
end
