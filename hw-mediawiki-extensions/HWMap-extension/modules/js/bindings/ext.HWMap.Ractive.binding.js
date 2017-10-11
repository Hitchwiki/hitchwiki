/**
 * Ensure Ractive.js is global (`window`)
 * @link https://www.mediawiki.org/wiki/ResourceLoader/Migration_guide_for_extension_developers#Troubleshooting_and_tips
 */
window.Ractive = Ractive;

/**
 * Configure Ractive.js debug mode
 * http://www.ractivejs.org/
 */
window.Ractive.DEBUG = Boolean(mw.config.get('debug'));

mw.log('window.Ractive.DEBUG: ' + window.Ractive.DEBUG);
