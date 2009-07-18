module TreasureHuntsHelper
  def prettyprint_blockinline(xml, xpath)
    doc = Nokogiri::XML(xml)
    para_syntax = doc.root.namespace.nil? ? "para" : "thunt:para"
    para = doc.root.xpath("#{xpath}/#{para_syntax}")
    pretty = ""
    xslt = Nokogiri::XSLT(File.read("#{RAILS_ROOT}/lib/active_treasure_hunt/prettyprint_blockinline.xslt"))
    para.each { |block| pretty << xslt.apply_to(Nokogiri::XML(block.to_xml)).to_a[1..-1].to_s }
    pretty
  end
end
