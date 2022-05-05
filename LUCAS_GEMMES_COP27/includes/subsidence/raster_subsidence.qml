<!DOCTYPE qgis PUBLIC 'http://mrcc.com/qgis.dtd' 'SYSTEM'>
<qgis hasScaleBasedVisibilityFlag="0" maxScale="0" version="3.24.2-Tisler" styleCategories="AllStyleCategories" minScale="1e+08">
  <flags>
    <Identifiable>1</Identifiable>
    <Removable>1</Removable>
    <Searchable>1</Searchable>
    <Private>0</Private>
  </flags>
  <temporal enabled="0" mode="0" fetchMode="0">
    <fixedRange>
      <start></start>
      <end></end>
    </fixedRange>
  </temporal>
  <customproperties>
    <Option type="Map">
      <Option value="false" name="WMSBackgroundLayer" type="bool"/>
      <Option value="false" name="WMSPublishDataSourceUrl" type="bool"/>
      <Option value="0" name="embeddedWidgets/count" type="int"/>
      <Option value="Value" name="identify/format" type="QString"/>
    </Option>
  </customproperties>
  <pipe-data-defined-properties>
    <Option type="Map">
      <Option value="" name="name" type="QString"/>
      <Option name="properties"/>
      <Option value="collection" name="type" type="QString"/>
    </Option>
  </pipe-data-defined-properties>
  <pipe>
    <provider>
      <resampling maxOversampling="2" enabled="false" zoomedInResamplingMethod="nearestNeighbour" zoomedOutResamplingMethod="nearestNeighbour"/>
    </provider>
    <rasterrenderer alphaBand="-1" opacity="1" classificationMax="3" classificationMin="0" band="1" type="singlebandpseudocolor" nodataColor="">
      <rasterTransparency/>
      <minMaxOrigin>
        <limits>None</limits>
        <extent>WholeRaster</extent>
        <statAccuracy>Estimated</statAccuracy>
        <cumulativeCutLower>0.02</cumulativeCutLower>
        <cumulativeCutUpper>0.98</cumulativeCutUpper>
        <stdDevFactor>2</stdDevFactor>
      </minMaxOrigin>
      <rastershader>
        <colorrampshader colorRampType="INTERPOLATED" clip="0" minimumValue="0" labelPrecision="4" classificationMode="1" maximumValue="3">
          <colorramp name="[source]" type="gradient">
            <Option type="Map">
              <Option value="255,251,252,17" name="color1" type="QString"/>
              <Option value="29,87,44,255" name="color2" type="QString"/>
              <Option value="ccw" name="direction" type="QString"/>
              <Option value="0" name="discrete" type="QString"/>
              <Option value="gradient" name="rampType" type="QString"/>
              <Option value="rgb" name="spec" type="QString"/>
              <Option value="0.05;198,255,225,255;rgb;ccw:0.1;167,255,196,255;rgb;ccw:0.166667;87,192,131,255;rgb;ccw:0.333333;47,122,94,255;rgb;ccw" name="stops" type="QString"/>
            </Option>
            <prop v="255,251,252,17" k="color1"/>
            <prop v="29,87,44,255" k="color2"/>
            <prop v="ccw" k="direction"/>
            <prop v="0" k="discrete"/>
            <prop v="gradient" k="rampType"/>
            <prop v="rgb" k="spec"/>
            <prop v="0.05;198,255,225,255;rgb;ccw:0.1;167,255,196,255;rgb;ccw:0.166667;87,192,131,255;rgb;ccw:0.333333;47,122,94,255;rgb;ccw" k="stops"/>
          </colorramp>
          <item value="0" color="#fffbfc" label="0.0000" alpha="17"/>
          <item value="0.15" color="#c6ffe1" label="0.1500" alpha="255"/>
          <item value="0.3" color="#a7ffc4" label="0.3000" alpha="255"/>
          <item value="0.5" color="#57c083" label="0.5000" alpha="255"/>
          <item value="1" color="#2f7a5e" label="1.0000" alpha="255"/>
          <item value="3" color="#1d572c" label="3.0000" alpha="255"/>
          <rampLegendSettings suffix="" prefix="" direction="0" maximumLabel="" minimumLabel="" orientation="2" useContinuousLegend="1">
            <numericFormat id="basic">
              <Option type="Map">
                <Option value="" name="decimal_separator" type="QChar"/>
                <Option value="6" name="decimals" type="int"/>
                <Option value="0" name="rounding_type" type="int"/>
                <Option value="false" name="show_plus" type="bool"/>
                <Option value="true" name="show_thousand_separator" type="bool"/>
                <Option value="false" name="show_trailing_zeros" type="bool"/>
                <Option value="" name="thousand_separator" type="QChar"/>
              </Option>
            </numericFormat>
          </rampLegendSettings>
        </colorrampshader>
      </rastershader>
    </rasterrenderer>
    <brightnesscontrast brightness="0" contrast="0" gamma="1"/>
    <huesaturation grayscaleMode="0" colorizeRed="255" colorizeBlue="128" invertColors="0" colorizeOn="0" colorizeStrength="100" saturation="0" colorizeGreen="128"/>
    <rasterresampler maxOversampling="2"/>
    <resamplingStage>resamplingFilter</resamplingStage>
  </pipe>
  <blendMode>0</blendMode>
</qgis>
