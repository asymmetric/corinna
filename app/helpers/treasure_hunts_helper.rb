module TreasureHuntsHelper
  def prettyprint_blockinline(xml, xpath)
    doc = Nokogiri::XML(xml)
    block = Nokogiri::XML(doc.root.xpath(xpath).to_xml)
    xslt = Nokogiri::XSLT(File.read("#{RAILS_ROOT}/lib/active_treasure_hunt/prettyprint_blockinline.xslt"))
    xslt.apply_to(block).to_a[1..-1].to_s
  end
end
