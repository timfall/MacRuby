require 'rdoc/markup/to_rdoc'

##
# Outputs RDoc markup with vibrant ANSI color!

class RDoc::Markup::ToAnsi < RDoc::Markup::ToRdoc

  ##
  # Creates a new ToAnsi visitor that is ready to output vibrant ANSI color!

  def initialize
    super

    @headings.clear
    @headings[1] = ["\e[1;32m", "\e[m"]
    @headings[2] = ["\e[4;32m", "\e[m"]
    @headings[3] = ["\e[32m",   "\e[m"]
  end

  ##
  # Maps attributes to ANSI sequences

  def init_tags
    add_tag :BOLD, "\e[1m", "\e[m"
    add_tag :TT,   "\e[7m", "\e[m"
    add_tag :EM,   "\e[4m", "\e[m"
  end

  ##
  # Overrides indent width to ensure output lines up correctly.

  def accept_list_item_end list_item
    width = case @list_type.last
            when :BULLET then
              2
            when :NOTE, :LABEL then
              @res << "\n" unless res.length == 1
              2
            else
              bullet = @list_index.last.to_s
              @list_index[-1] = @list_index.last.succ
              bullet.length + 2
            end

    @indent -= width
  end

  ##
  # Adds coloring to note and label list items

  def accept_list_item_start list_item
    bullet = case @list_type.last
             when :BULLET then
               '*'
             when :NOTE, :LABEL then
               attributes(list_item.label) + ":\n"
             else
               @list_index.last.to_s + '.'
             end

    case @list_type.last
    when :NOTE, :LABEL then
      @indent += 2
      @prefix = bullet + (' ' * @indent)
    else
      @prefix = (' ' * @indent) + bullet.ljust(bullet.length + 1)

      width = bullet.gsub(/\e\[[\d;]*m/, '').length + 1

      @indent += width
    end
  end

  ##
  # Starts accepting with a reset screen

  def start_accepting
    super

    @res = ["\e[0m"]
  end

end

