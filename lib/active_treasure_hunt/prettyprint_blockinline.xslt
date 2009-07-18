<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fb="www.facebook.com">
  <xsl:template match ="para">
    <xsl:apply-templates /><br />
  </xsl:template>
  <xsl:template match="bold">
    <b><xsl:apply-templates /></b>
  </xsl:template>
  <xsl:template match="italic">
    <i><xsl:apply-templates /></i>
  </xsl:template>
  <xsl:template match="link">
    <a href="{@href}"><xsl:value-of select="@href"/></a>
    <xsl:apply-templates />
  </xsl:template>
  <xsl:template match="image">
    <xsl:if test="@type = 'inline'"><span><img src="{@src}"/></span></xsl:if>
    <xsl:if test="@type = 'block'"><p><img src="{@src}"/></p></xsl:if>
    <xsl:apply-templates />
  </xsl:template>
  <xsl:template match="location">
    <p>
      <fb:iframe width="760" height="570" frameborder="0" scrolling="no" marginheight="0" marginwidth="0" src="http://corinna.bucket.mine.nu/maps?lat={@lat}&amp;lng={@long}&amp;z=16"></fb:iframe>
    </p>
    <xsl:apply-templates />
  </xsl:template>
  <xsl:template match="picture">
    <xsl:if test="@type = 'flickr'"><a href="http://www.flickr.com/photos/{@usr}/{@id}">Flickr image!</a></xsl:if>
    <xsl:apply-templates/>
  </xsl:template>
  <xsl:template match="video">
    <xsl:if test="@type = 'youtube'">
      <p><fb:swf swfbgcolor="000000" imgstyle="border-width:3px; border-color:white;" swfsrc='http://www.youtube.com/v/{@id}' width='340' height='270' /></p>
      <p><a href="http://www.youtube.com/?v={@id}"><img src="http://i4.ytimg.com/vi/{@id}/default.jpg "/></a></p>
    </xsl:if>
    <xsl:if test="@type = 'googlevideo'">
      <p><fb:swf swfbgcolor="000000" imgstyle="border-width:3px; border-color:white;" swfsrc='http://video.google.com/videoplay?docid={@id}' width='340' height='270' /></p>
      <p><a href="http://video.google.com/videoplay?docid={@id}">Google Video!</a></p>		
    </xsl:if>
    <xsl:apply-templates />
  </xsl:template>
  <xsl:template match="article">
    <a href="http://{@lang}.wikipedia.org/wiki/{@id}">Wikipedia!<br />
      <img src="http://upload.wikimedia.org/wikipedia/meta/2/2a/Nohat-logo-nowords-bgwhite-200px.jpg" height="100" width="100" />
    </a>
    <xsl:apply-templates />
  </xsl:template>
</xsl:stylesheet>
