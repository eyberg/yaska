module Colorify
  def colorBlack(text)
    return "\033[1m\033[30m\033[40m #{text} \033[0m"
  end

  def colorWhite(text)
    return "\033[1m\033[37m\033[40m #{text} \033[0m"
  end

  def colorGreen(text)
    return "\033[1m\033[32m\033[40m #{text} \033[0m"
  end

  def colorYellow(text)
    return "\033[1m\033[33m\033[40m #{text} \033[0m"
  end

  def colorRed(text)
    return "\033[1m\033[31m\033[40m #{text} \033[0m"
  end

  def colorBlue(text)
    return "\033[1m\033[34m\033[40m #{text} \033[0m"
  end
end
