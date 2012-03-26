class PDFConverter

  # @todo store files in a proper place
  # @todo add yardoc comments for classes and methods in this file
  def self.convert_webpage_to_pdf(url, title)
    kit = PDFKit.new(url)
    file_path = title.downcase.gsub(/[^a-zA-Z0-9 ]/, '').gsub(/\ +/, '-').gsub(/\-$/, '').gsub(/^\-/, '')
    file_path = 'temp/' + file_path + '.pdf'
    kit.to_file('./' + file_path)
    file_path
  end

end
