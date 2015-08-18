module ApsHelper

  def sanitize(str)
    # for proper jquery input when there are periods involved
    str.gsub('.','\\\\\.')
  end

end
