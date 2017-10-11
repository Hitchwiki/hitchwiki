<?php

namespace HWLI;

use SMWQueryProcessor as QueryProcessor;
use Parser;
use Html;

/**
 * @license MIT
 * @since 1.0
 *
 * @author Mikael Korpela
 */
class HWLocationInput {

  /**
   * @var Parser
   */
  private $parser;

  /**
   * @since 1.0
   *
   * @param Parser $parser
   */
  public function __construct( &$parser ) {
    $this->parser = $parser;
  }

  /**
   * @since 1.0
   *
   * @return string
   */
  public static function init($value, $inputName, $isMandatory, $isDisabled, $otherArgs) {
    $instance = new self($GLOBALS['wgParser']);
    return $instance->locationInput($value, $inputName, $isMandatory, $isDisabled, $otherArgs);
  }

  public function locationInput($value, $inputName, $isMandatory, $isDisabled, $otherArgs) {
    global $wgHWLICount; // Keeps the count how many of locationInput's we already created

    if ($wgHWLICount == 0 ) {
      // Loads javascript, but only once
      Output::addModule('ext.HWLocationInput');
    }
    $wgHWLICount++;

    // $size_regexp = '/\d*\.?\d+(?:px|%)?/i';
    $width = array_key_exists('width', $otherArgs) ? strip_tags($otherArgs['width']) : '100%';
    $height = array_key_exists('height', $otherArgs) ? strip_tags($otherArgs['height']) : '300px';
    $zoom = array_key_exists('zoom', $otherArgs) ? intval($otherArgs['zoom']) : 5;

    // https://doc.wikimedia.org/mediawiki-core/1.28.0/php/classHtml.html
    // https://www.mediawiki.org/wiki/Manual:Html.php
    $html = Html::element('div',
      array(
        'class' => 'hw_location_map',
        'id' => 'hw_location_map_' . $wgHWLICount,
        'style' => 'width:' . $width . ';' .
                   'height:' . $height . ';',
        'data-field-number' => $wgHWLICount,
        'data-zoom' => $zoom
      )
    );

    // Arguments for input DOM element
    $inputArgs = array(
      'type' => 'text', // hidden
      'style' => 'width:100%', // to be removed
      'name' => $inputName,
      'id' => 'hw_location_input_' . $wgHWLICount,
      'value' => $value
    );

    // Input is disabled
    if ($isDisabled) {
      $inputArgs['disabled'] = 'disabled';
    }

    // Input is mandatory
    if ($isMandatory) {
      $inputArgs['class'] = 'mandatoryField';
    }

    $html .= Html::element('input', $inputArgs);

    $html .= Html::element('span', array(
      'id' => 'info_' . $wgHWLICount,
      'class' => 'errorMessage'
    ));

    Output::commitToParserOutput($this->parser->getOutput());

    return $html;
  }

}
