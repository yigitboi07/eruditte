# Copyright (c) 2009-2017 Minero Aoki, Kenshi Muto
#               2002-2008 Minero Aoki
#
# This program is free software.
# You can distribute or modify this program under the terms of
# the GNU LGPL, Lesser General Public License version 2.1.
# For details of the GNU LGPL, see the file "COPYING".
#
require 'review/textutils'
require 'review/index_builder'

module ReVIEW
  module Book
    class BookUnit
      include TextUtils
      attr_reader :book
      attr_reader :path
      attr_reader :lines
      attr_accessor :content

      attr_reader :list_index, :table_index, :equation_index, :footnote_index,
                  :numberless_image_index, :image_index, :icon_index, :indepimage_index,
                  :headline_index, :column_index

      def initialize
        if @content
          @lines = content.lines
        end
      end

      def make_indexes
        index_builder = ReVIEW::IndexBuilder.new
        compiler = ReVIEW::Compiler.new(index_builder)
        compiler.compile(self)
        index_builder
      end

      def generate_indexes
        return unless content

        @lines = content.lines

        @indexes = make_indexes

        @list_index = @indexes.list_index
        @table_index = @indexes.table_index
        @equation_index = @indexes.equation_index
        @footnote_index = @indexes.footnote_index
        @headline_index = @indexes.headline_index
        @column_index = @indexes.column_index
      end

      def dirname
        @path && File.dirname(@path)
      end

      def basename
        @path && File.basename(@path)
      end

      def name
        @name && File.basename(@name, '.*')
      end

      alias_method :id, :name

      def title
        return @title if @title

        @title = ''
        return @title unless content
        content.each_line do |line|
          if line =~ /\A=+/
            @title = line.sub(/\A=+(\[.+?\])?(\{.+?\})?/, '').strip
            break
          end
        end
        @title
      end

      def size
        content.size
      end

      def volume
        @volume ||= Volume.count_file(path)
      end

      def list(id)
        list_index[id]
      end

      def table(id)
        table_index[id]
      end

      def equation(id)
        equation_index[id]
      end

      def footnote(id)
        footnote_index[id]
      end

      def image(id)
        return image_index[id] if image_index.key?(id)
        return icon_index[id] if icon_index.key?(id)
        return numberless_image_index[id] if numberless_image_index.key?(id)
        indepimage_index[id]
      end

      def bibpaper(id)
        bibpaper_index[id]
      end

      def bibpaper_index
        raise FileNotFound, "no such bib file: #{@book.bib_file}" unless @book.bib_exist?
        @bibpaper_index
      end

      def headline(caption)
        headline_index[caption]
      end

      def column(id)
        column_index[id]
      end

      def next_chapter
        book.next_chapter(self)
      end

      def prev_chapter
        book.prev_chapter(self)
      end

      def image_bound?(item_id)
        image(item_id).path
      end
    end
  end
end
