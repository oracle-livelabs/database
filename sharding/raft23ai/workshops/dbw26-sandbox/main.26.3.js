/*
 * ============================================
 * Oracle LiveLabs Workshop Framework
 * Version: 26.3
 * ============================================
 *
 * Version     Date             Author          Summary
 * ---------------------------------------------------------
 * 21.9        Feb-14-22       Kevin Lazarz    Added fix for LLAPEX-403 (accessible html tables)
 * 22.0        Feb-14-22       Kevin Lazarz    Added alt-text fix - add alt attribute to all images which do not have alt
 * 22.1        Feb-15-22       Kevin Lazarz    Added fix for landmark issue (LLAPEX-401) and list issue (LLAPEX-400)
 * 22.2        Feb-17-22       Kevin Lazarz    Role back LLAPEX-400 due issues in some workshops
 * 22.3        Mar-08-22       Kevin Lazarz    Temp fix for list issues LLAPEX-400, added QA check for images missing alt-text, changed numbering for table header
 * 22.4        Mar-30-22       Ashwin Agarwal  Added alt-text for modal images (LLAPEX-431)
 * 22.5        Apr-1-22        Ashwin Agarwal  Created global main.js (merge main.js * main.sprint.js) - LLAPEX-440
 * 22.6        Apr-18-22       Ashwin Agarwal  Accessibility bugs in JavaScript - anchor not in <li> - LLAPEX-400
 * 22.7        Apr-20-22       Ashwin Agarwal  Add a static header for sprints - LLAPEX-448
 * 22.8        May-09-22       Ashwin Agarwal  Single sourcing does not work for included files - LLAPEX-477
 * 22.9        Jun-01-22       Ashwin Agarwal  Remove header, custom table caption (LLAPEX-418), hide expand/collapse button (LLAPEX-465), variables (LLAPEX-487), object storage URL changes (LLAPEX-488)
 * 22.10       Jun-01-22       Ashwin Agarwal  Remove feature where the expand/collapse button disappears when there are less than or equal to 2 h2 sections
 * 22.11       Jun-15-22       Ashwin Agarwal  Relative path incorrect for included files (LLAPEX-480)
 * 22.12       Jul-15-22       Kevin Lazarz    Replace object storage links with github.io link
 * 23.0        Aug-24-22       Kevin Lazarz    Added code to allow embedding videos from Oracle Video Hub (LLAPEX-559)
 * 23.1        Sep-21-22       Kevin Lazarz    Fix for LLAPEX-595
 * 23.2        Nov-10-22       Kevin Lazarz    Added LLAPEX-637 & LLAPEX-642
 * 23.3        Mar-13-23       Dan Williams    Provided an example of imperative text (eg.'Start' not 'Starting) (LLAPEX-699)
 * 23.4        Mar-17-23       Dan Williams    Updated imperative text ( eg. 'Start' not 'Starting') to include where issue is within Lab (LLAPEX-701)
 * 23.4.1      Oct-24-24       Kevin Lazarz    Fixed Lintchecker
 * 23.5        Oct-24-24       Kaylien Phan    Fixing "includes" functionality to accommodate for CDN
 * 23.6        Mar-20-25       Brianna Ambler  Adding support for LiveSQL integration with LiveLabs sprints
 * 23.7        Jan-06-26       Brianna Ambler  Renaming LiveSQL to FreeSQL
 * 23.8        Jan-22-26       Kevin Lazarz     Modernization: Clipboard API, error handling, code organization, JSDoc
 * 24.0        Jan-22-26       Kevin Lazarz     Added lazy loading images
 * 24.1        Jan-22-26       Kevin Lazarz     Added interactive quiz feature
 * 24.2        Jan-22-26       Kevin Lazarz     Added quiz scoring with badge download
 * 24.3        Jan-22-26       Kevin Lazarz     Enhanced badge UI with preview and disclaimer
 * 24.4        Jan-23-26       Kevin Lazarz     Auto-calculate estimated reading time for "Estimated Time: X" placeholder
 * 24.5        Jan-23-26       Kevin Lazarz     Added direct video file embedding support [](video:URL)
 * 25.0        Jan-28-26       Kevin Lazarz     SQL copy-to-clipboard: added trailing newline for ```sql blocks so last statement executes
 * 26.2        Feb-06-26       Kevin Lazarz     QA parity: removed gerund checks, synced script behavior
 * 26.3        Mar-13-26       Kevin Lazarz      FreeSQL iframe loader split into external module + loader wiring
 */

/*
 * ============================================
 * SECTION 1: CONFIGURATION & GLOBALS
 * ============================================
 */
"use strict";

var showdown = "https://oracle-livelabs.github.io/common/redwood-hol/js/showdown.min.js";
var highlight = "https://oracle-livelabs.github.io/common/redwood-hol/js/highlight.min.js";
var freesqlEmbedLoader = "https://oracle-livelabs.github.io/common/redwood-hol/js/freesql-embed-loader.min.js";

/**
 * Resolve the currently loaded main script URL.
 * Supports both versioned and minified file names.
 * @returns {string}
 */
function resolveCurrentMainScriptSource() {
    if (document.currentScript && document.currentScript.src) {
        return document.currentScript.src;
    }

    let scripts = document.getElementsByTagName("script");
    let mainPattern = /\/main(?:\.[0-9.]+)?(?:\.min)?\.js(?:[?#].*)?$/;

    for (let index = scripts.length - 1; index >= 0; index -= 1) {
        let src = scripts[index].src || "";
        if (mainPattern.test(src)) {
            return src;
        }
    }

    return "";
}


/** @constant {string} Base path for related workshops content */
const related_path = "https://oracle-livelabs.github.io/common/related/";

let main = function () {
    // Internal configuration
    let manifestFileName = "manifest.json";
    let expandText = "Expand All Tasks";
    let collapseText = "Collapse All Tasks";

    /** @constant {string} Current domain origin */
    const currentDomain = window.location.origin;
    console.log("Current domain:", currentDomain);

    /** @constant {string} Text displayed on copy buttons */
    const copyButtonText = "Copy";

    /** @constant {string} Query parameter name for lab selection */
    const queryParam = "lab";

    /** @constant {Array<Object>} UTM tracking parameter configurations */
    const utmParams = [
        {
            "url": "https://signup.cloud.oracle.com",
            "inParam": "customTrackingParam",
            "outParam": "sourceType"
        },
        {
            "url": "https://myservices.us.oraclecloud.com/mycloud/signup",
            "inParam": "customTrackingParam",
            "outParam": "sourceType"
        },
        {
            "url": "https://myservices.oraclecloud.com/mycloud/signup",
            "inParam": "customTrackingParam",
            "outParam": "sourceType"
        },
        {
            "url": "https://cloud.oracle.com",
            "inParam": "customTrackingParam",
            "outParam": "sourceType"
        }
    ];

    /** @constant {string} Query parameter name for navigation state */
    const nav_param_name = 'nav';

    /** @constant {string} Query parameter name for header visibility */
    const header_param_name = 'header';

    /** @constant {Object} Extended navigation hash mappings */
    const extendedNav = { '#last': 2, '#next': 1, '#prev': -1, "#first": -2 };

    $.ajaxSetup({ cache: true });

    /** @type {Object|null} Global manifest file reference */
    let manifest_global;

    /*
     * ============================================
     * SECTION 2: INITIALIZATION
     * ============================================
     */
    $(document).ready(function () {
        let manifestFileContent;
        if (getParam("manifest")) {
            manifestFileName = getParam("manifest");
        }

        let freeSqlLoaderReady = $.Deferred();
        $.getScript(freesqlEmbedLoader, function () {
            console.log("FreeSQL embed loader loaded!");
            freeSqlLoaderReady.resolve();
        }).fail(function (_jqXHR, _settings, exception) {
            console.warn("FreeSQL embed loader failed to load from " + freesqlEmbedLoader + ".", exception);
            freeSqlLoaderReady.resolve();
        });

        $.when(
            $.getScript(showdown, function () {
                console.log("Showdown library loaded!");
            }),
            $.getJSON(manifestFileName, function (manifestFile) {
                if (manifestFile.workshoptitle !== undefined) { // if manifest file contains a field for workshop title
                    document.getElementsByClassName("hol-Header-logo")[0].innerText = manifestFile.workshoptitle; // set title in the HTML output (DBDOC-2392)
                }
                console.log("Manifest file loaded!");


                if (getParam("manifest")) {
                    $(manifestFile.tutorials).each(function () {
                        if ($(this)[0].filename.indexOf("http") == -1 && $(this)[0].filename[0] !== "/") {
                            $(this)[0].filename = manifestFileName.substring(0, manifestFileName.lastIndexOf("/") + 1) + $(this)[0].filename;
                        }
                    });
                }

                // const currentDomain = window.location.origin; // e.g., "https://livelabs.oracle.com"
                // console.log("Current domain:", currentDomain);

                // Added for include feature: [DBDOC-2434] Include any file inside of Markdown before rendering
                for (let short_name in manifestFile.include) {
                    let include_fname = manifestFile.include[short_name];

                    if (include_fname.indexOf("http") === -1 && include_fname[0] !== "/") { // If the link is relative
                        include_fname = manifestFileName.substring(0, manifestFileName.lastIndexOf("/") + 1) + include_fname;
                    }

                    // Modify include_fname based on the current domain
                    if (include_fname.startsWith("/") && currentDomain.includes("livelabs.oracle.com")) {
                        include_fname = "/cdn/" + include_fname.replace(/^\/+/, ""); // Ensure correct path
                    } else if (include_fname.startsWith("/") && currentDomain.includes("apexapps-stage.oracle.com")) {
                        include_fname = "/livelabs/cdn/" + include_fname.replace(/^\/+/, ""); // Ensure correct path
                    }

                    console.log("Fetching:", include_fname);

                    $.get(include_fname, function (included_file_content) {
                        manifestFile.include[short_name] = {
                            'path': include_fname,
                            'content': included_file_content
                        };
                    }).fail(function () {
                        console.error("Failed to load:", include_fname);
                    });
                }

                if (manifestFile.variables) {
                    if (!Array.isArray(manifestFile.variables)) {
                        manifestFile['variables'] = Array(manifestFile.variables);
                    }
                    $(manifestFile.variables).each(function (_, i) {
                        let include_fname = i;
                        // console.log("Variables:" , include_fname);

                        // Modify include_fname based on the current domain
                        if (include_fname.startsWith("/") && currentDomain.includes("livelabs.oracle.com")) {
                            include_fname = "/cdn/" + include_fname.replace(/^\/+/, ""); // Ensure correct path
                        } else if (include_fname.startsWith("/") && currentDomain.includes("apexapps-stage.oracle.com")) {
                            include_fname = "/livelabs/cdn/" + include_fname.replace(/^\/+/, ""); // Ensure correct path
                        }
                        console.log("Variables:" , include_fname);

                        $.getJSON(include_fname, function (variables) {
                            if (!manifestFile['variable_values']) {
                                manifestFile['variable_values'] = {};
                            }
                            $.extend(manifestFile['variable_values'], variables);
                        });
                    })
                }

                manifest_global = manifestFileContent = manifestFile; //reading the manifest file and storing content in manifestFileContent variable                
            }),
            $.getScript(highlight, function () {
                console.log("Highlight.js loaded!");
            }),
            freeSqlLoaderReady.promise()
        ).done(function () {
            init();
            let selectedTutorial = setupTutorialNav(manifestFileContent); //populate side navigation based on content in the manifestFile            
            let articleElement = document.createElement('article'); //creating an article that would contain MD to HTML converted content

            loadTutorial(articleElement, selectedTutorial, manifestFileContent, toggleTutorialNav);

            prepareToc(manifestFileContent);
            setupRelatedSection(manifestFileContent);

            setTimeout(function () {
                if (location.hash.slice(1))
                    expandSectionBasedOnHash($("li[data-unique='" + location.hash.slice(1) + "']"));

                if ($('#leftNav-toc').hasClass('scroll'))
                    $('.selected')[0].scrollIntoView(true);
            }, 1000);
        });
    });

    // specifies when to do when window is scrolled
    $(window).scroll(function () {
        // if ($('#contentBox').height() > $('#leftNav-toc').height() || ($('#leftNav-toc').height() + $('header').height()) > $(window).height()) {
        if (($('#contentBox').outerHeight() + $('header').outerHeight() + $('footer').outerHeight()) > $(window).outerHeight()) {
            $('#leftNav-toc').addClass("scroll");

            if (($(window).scrollTop() + $(window).height()) > $('footer').offset().top) { //if footer is seen
                $('#leftNav-toc').css('max-height', $('footer').offset().top - $('#leftNav-toc').offset().top);
            } else {
                $('#leftNav-toc').css('max-height', $(window).height() - $('header').height());
            }
        } else {
            $('#leftNav-toc').removeClass("scroll");
        }

        try {
            if ((document.querySelector('.selected .active').getBoundingClientRect().y + document.querySelector('.selected .active').clientHeight) > $(window).height() && $('#leftNav-toc').hasClass("scroll"))
                $('.selected .active')[0].scrollIntoView(false);
        } catch (e) { console.debug('TOC scroll error:', e); }

        let active = $('#contentBox').find('[data-unique]').first();
        $('#contentBox').find('[data-unique]').each(function () {
            if (($(this).offset().top - $(window).scrollTop() - $('header').height()) < Math.abs($(active).offset().top - $(window).scrollTop())) {
                active = $(this);
            }
        });
        $('.selected .toc .toc-item').removeClass('active');
        $('.selected .toc').find('[data-unique="' + $(active).attr('data-unique') + '"]').addClass('active');
    });

    $(window).on('hashchange load', function (e) {
        try { // if next or previous is not available then it raises exception
            let position = extendedNav[e.target.location.hash]
            if (position !== undefined)
                changeTutorial(getMDFileName(selectTutorial(manifest_global, position).filename));

            setTimeout(function () {
                // Cause a subtle change in the parent page to trigger Google Translate
                // if (window.parent && window.parent.document) {
                    let body = window.parent.document.body;
            
                    // Find or create a subtle trigger element
                    let triggerElement = window.parent.document.getElementById("translation-trigger");
                    if (!triggerElement) {
                        triggerElement = window.parent.document.createElement("span");
                        triggerElement.id = "translation-trigger";
                        triggerElement.style.display = "none"; // Keep it invisible
                        body.appendChild(triggerElement);
                    }
            
                    // Toggle text content to force translation detection
                    triggerElement.textContent = triggerElement.textContent === "." ? " " : ".";
                    console.log("Translation trigger updated:", triggerElement);
                // }
            }, 500); // Adjust delay as needed
        } catch (e) { console.debug('Hash change error:', e); }
    });

    let init = function () {
        // hide header if the url contains header=hide
        let header_param = getParam(header_param_name);
        if (header_param == 'hide') {
            $('header').hide();
            $('body').css("padding-top", "0px");
        }
        // $('.hol-Header-actions').prependTo('.hol-Header-wrap').show();
        $('.hol-Header-actions').prependTo('.hol-Header-wrap');
        $('<div id="tutorial-title"></div>').appendTo(".hol-Header-logo")[0];

        $('#openNav').click(function () {
            let nav_param = getParam(nav_param_name);
            if (!nav_param || nav_param === 'open') {
                window.history.pushState('', '', setParam(window.location.href, nav_param_name, 'close'));
            } else if (nav_param === 'close') {
                window.history.pushState('', '', setParam(window.location.href, nav_param_name, 'open'));
            }
            toggleTutorialNav();
        });

        $('.hol-Footer-topLink').after($(document.createElement('a')).addClass('hol-Footer-rightLink hide'));
        $('.hol-Footer-topLink').before($(document.createElement('a')).addClass('hol-Footer-leftLink hide'));
        $('#contentBox').css('min-height', $(window).height() - $('header').outerHeight() - $('footer').outerHeight());
        $('.hol-Header-actions').show('slide');
    }

    /*
     * ============================================
     * SECTION 3: MARKDOWN PROCESSING
     * ============================================
     */

    /**
     * Loads and renders a tutorial from markdown
     * @param {HTMLElement} articleElement - Container for rendered content
     * @param {Object} selectedTutorial - Tutorial object from manifest
     * @param {Object} manifestFileContent - Full manifest configuration
     * @param {Function} [callbackFunc=null] - Optional callback after load
     */
    const loadTutorial = function (articleElement, selectedTutorial, manifestFileContent, callbackFunc = null) {
        let tut_fname;

        // const currentDomain = window.location.origin; // e.g., "https://livelabs.oracle.com"
        // console.log("Current domain:", currentDomain);

        // Modify tut_fname based on the current domain
        if (selectedTutorial.filename.startsWith("/") && currentDomain.includes("livelabs.oracle.com")) {
            tut_fname = "/cdn/" + selectedTutorial.filename.replace(/^\/+/, ""); // Ensure correct path
        } else if (selectedTutorial.filename.startsWith("/") && currentDomain.includes("apexapps-stage.oracle.com")) {
            tut_fname = "/livelabs/cdn/" + selectedTutorial.filename.replace(/^\/+/, ""); // Ensure correct path
        } else {
            tut_fname = selectedTutorial.filename;
        }

        $.get(tut_fname, function (markdownContent) { //reading MD file in the manifest and storing content in markdownContent variable
            console.log(tut_fname + " loaded!");

            if (selectedTutorial.filename == 'preview' && markdownContent == "None") {
                markdownContent = window.localStorage.getItem("mdValue");
            }

            markdownContent = include(markdownContent, manifestFileContent.include); // added for include feature: [DBDOC-2434] Include any file inside of Markdown before rendering
            markdownContent = substituteVariables(markdownContent, manifestFileContent.variable_values); // added for variable feature
            markdownContent = calculateEstimatedTime(markdownContent); // calculates and replaces "Estimated Time: X" placeholder
            markdownContent = singlesource(markdownContent, selectedTutorial.type); // implement show/hide feature based on the if tag (DBDOC-2430)
            markdownContent = convertFreeSQLButtonTags(markdownContent); // converts <freesql-button> tags to actual FreeSQL buttons
            markdownContent = convertBracketInsideCopyCode(markdownContent); // converts <> tags inside copy tag to &lt; and &gt; (DBDOC-2404)
            markdownContent = addPathToImageSrc(markdownContent, tut_fname); //adding the path for the image based on the filename in manifest
            markdownContent = addPathToTypeHrefs(markdownContent); // if type is specified in the markdown, then add absolute path for it.
            markdownContent = convertSingleLineCode(markdownContent);
            markdownContent = convertQuizBlocks(markdownContent); // converts ```quiz blocks to interactive quiz HTML
            markdownContent = convertCodeBlocks(markdownContent); // codeblock with multiple breaks don't render correctly, so I convert to codeblock here itself

            $(articleElement).html(new showdown.Converter({
                tables: true, //allows tables to rendered
                parseImgDimensions: true, //allows image dimension to be specified in the markdown
                metadata: true, // allows metadata to be added between --- and --- tags at the top of the markdown
                simplifiedAutoLink: true, //transform http addresses automatically in to clickable URLs in HTML
                strikethrough: true //allow strikethrough formatting
            }).makeHtml(markdownContent)); //converting markdownContent to HTML by using showdown plugin

            articleElement = updateOpenCloseButtonText(articleElement, manifestFileContent); // in the manifest file, you can specify task_type to specify different text
            articleElement = showRightAndLeftArrow(articleElement, manifestFileContent);
            articleElement = renderVideoHubVideos(articleElement); //adds iframe to Oracle Video Hub videos
            articleElement = renderYouTubeVideos(articleElement); //adds iframe to YouTube videos
            articleElement = renderDirectVideos(articleElement); //adds HTML5 video element for direct video URLs
            articleElement = updateH1Title(articleElement); //adding the h1 title in the Tutorial before the container div and removing it from the articleElement
            articleElement = wrapSectionTag(articleElement); //adding each section within section tag
            articleElement = wrapImgWithFigure(articleElement); //Wrapping images with figure, adding figcaption to all those images that have title in the MD
            articleElement = addPathToAllRelativeHref(articleElement, tut_fname); //adding the path for all HREFs based on the filename in manifest
            articleElement = setH2Name(articleElement);
            articleElement = makeAnchorLinksWork(articleElement); //if there are links to anchors (for example: #hash-name), this function will enable it work
            articleElement = addTargetBlank(articleElement); //setting target for all ahrefs to _blank
            articleElement = allowCodeCopy(articleElement); //adds functionality to copy code from codeblocks
            articleElement = enableForceDownload(articleElement); // enables the force download feature (?download=1 must be mentioned at the end of the URL)
            articleElement = injectUtmParams(articleElement);
            articleElement = showTabs(articleElement, selectedTutorial.type); //show type options as tabs (DBDOC-2455)
            articleElement = highlightCodeBlock(articleElement); // highlights the code in the codeblock (DBDOC-2494)
            articleElement = addModalWindow(articleElement); // add modal window so that images open in full screen when clicked (DBDOC-2575)
            updateHeadContent(selectedTutorial, manifestFileContent.workshoptitle); //changing document head based on the manifest

            // adding link to the support forum URL in the footer if the manifest file contains it (DBDOC-2459 and DBDOC-2496)
            addGoToForumLink(manifestFileContent.support);
            // adding social media link to the header
            // addSocialMediaLink(manifestFileContent.help, manifestFileContent.workshoptitle);
            // adding link to the Neep Help URL in the header if the manifest file contains it (DBDOC-2496)
            
            // KP Translate 
            $(document).ready(function () {
                addTranslateIcon(manifestFileContent.help); 
            
                $(document).on('click', function (e) {
                    if (!$(e.target).closest('#translate_icon, #translate_popup').length) {
                        $('#translate_popup').hide();
                    }
                });
            });
            addNeedHelpLink(manifestFileContent.help);

            if (getParam("qa") == "true") {
                articleElement = performQA(articleElement, markdownContent, manifestFileContent);
            }
        }).done(function () {
            $("main").html(articleElement); //placing the article element inside the main tag of the Tutorial template
            setTimeout(function () {
                setupContentNav(manifestFileContent, articleElement);
            }, 0); //sets up the collapse/expand button and open/close section feature



            //FOllowing code will make sure that landmarks have a unique title (LLAPEX-401)
            document.getElementsByTagName("header")[0].setAttribute("title", "livelabs header");
            document.getElementsByTagName("main")[0].setAttribute("title", "livelabs main");
            document.getElementsByTagName("footer")[0].setAttribute("title", "livelabs footer");
            //END of fix for landmarks

            // Following code makes tables accessible (see LLAPEX-403)
            $("table").attr("role", "presentation"); //add role to table

            var i = 0;
            var tables = document.getElementsByTagName("table");
            let title = document.querySelector('title').innerText;
            let caption_start = '{: title="';

            for (i; i < tables.length; i++) {
                var table = tables[i];
                var capt = table.createCaption();
                let given_title = null;
                let next_element = $($(tables)[i]).find('tr').last();
                if (next_element.text().trim().startsWith(caption_start)) {
                    given_title = next_element.text().trim().replace(caption_start, "");
                    given_title = given_title.replace('"}', "");
                    $(next_element).remove();
                }
                var tit = capt.textContent = 'Table ' + (i + 1) + ': ' + (given_title || title);
                table.setAttribute("role", "presentation");
            };
            // END OF TABLE ACCESSIBILITY ENHANCEMENT

            if (selectedTutorial.filename == 'preview') {
                let uploaded_images = JSON.parse(window.localStorage.getItem("imagesValue"));

                // added for showing images in preview
                if (uploaded_images !== null) {
                    $('main').find('img').each(function (i, imageFile) {
                        for (let i = 0; i < uploaded_images.length; i++) {
                            if ($(imageFile).attr('src').indexOf(uploaded_images[i].filename) >= 0) {
                                $(imageFile).attr('src', uploaded_images[i].src);
                            }
                        }
                    });
                }
            }

            if (getParam("qa") == "true") {
                dragElement(document.getElementById("qa-report"));
            } else {
                collapseSection($("#module-content h2:not(:eq(0))"), "none"); //collapses all sections by default
            }

            if (callbackFunc)
                callbackFunc();

        }).fail(function () {
            console.log(selectedTutorial.filename + ' not found! Please check that the file is available in the location provided in the manifest file.');
        });
    }

    let convertSingleLineCode = function (markdown) {
        let regex_type = new RegExp(/`{3,4}(.*?)`{3,4}/g);
        let contentToReplace = [];

        let matches;
        do {
            matches = regex_type.exec(markdown);
            if (matches === null) {
                $(contentToReplace).each(function (index, value) {
                    markdown = markdown.replace(value.replace, value.with);
                });
                return markdown;
            }

            contentToReplace.push({
                "replace": matches[0],
                "with": '`' + matches[1] + '`'
            });

        } while (matches);
    }

    //DBDOC-2591: Code blocks break when line breaks (empty lines) are added
    let convertCodeBlocks = function (markdown) {
        let regex_type = new RegExp(/`{3,}(.*?)\n([\s\S|\n]*?)`{3,}/g);
        let matches, remove, remove_space_regex;
        let contentToReplace = [];

        do {
            let pre_tag = "<pre>";
            matches = regex_type.exec(markdown);
            if (matches === null) {
                $(contentToReplace).each(function (index, value) {
                    // replace using split because the string has regex
                    markdown = markdown.split(value.replace).join(value.with);
                });
                return markdown;
            }
            // else
            remove = matches[2].substring(0, matches[2].indexOf(matches[2].trim())).replace(/\t/g, '    ');
            // remove_space_regex = new RegExp("^" + remove, "gm");

            if (matches[1].trim().length !== 0) {
                pre_tag = '<pre class="' + matches[1].trim() + '">';
            }

            let replace_with = matches[2].replace(/\t/g, '    ').split('\n');

            for (let i = 0; i < replace_with.length; i++) {
                replace_with[i] = replace_with[i].replace(remove, '');
            }
            replace_with = replace_with.join('\n');

            contentToReplace.push({
                "replace": matches[0],
                "with": pre_tag + '<code>' + replace_with.trim() + '</code></pre>'
                // "with": pre_tag + '<code>' + matches[2].replace(/(?=[\r\n])\r?\n?/g,"\n") + '</code></pre>'
                // "with": pre_tag + '<code>' + matches[2].replace(remove_space_regex, '').trim().replace(/\t/g, '') + '</code></pre>'
            });
        } while (matches);
    }

    /**
     * Converts ```quiz-config blocks to store quiz scoring configuration
     * Syntax:
     *   passing: 80
     *   badge: images/badge.png
     */
    let convertQuizConfig = function (markdown) {
        let configRegex = /`{3,}quiz-config\s*\n([\s\S]*?)`{3,}/g;

        return markdown.replace(configRegex, function (match, content) {
            let config = {
                passing: 80,
                badge: null
            };

            let lines = content.trim().split('\n');
            lines.forEach(function (line) {
                // Allow optional whitespace at start of line
                let passingMatch = line.match(/^\s*passing:\s*(\d+)/i);
                let badgeMatch = line.match(/^\s*badge:\s*(.+)/i);

                if (passingMatch) {
                    config.passing = parseInt(passingMatch[1], 10);
                }
                if (badgeMatch) {
                    config.badge = badgeMatch[1].trim();
                }
            });

            // Return a hidden div with config data
            return '<div id="ll-quiz-config" data-passing="' + config.passing + '" data-badge="' + (config.badge || '') + '" style="display:none;"></div>';
        });
    }

    /**
     * Converts ```quiz code blocks to interactive quiz HTML
     * Syntax:
     *   Q: Question text here
     *   * Correct answer (asterisk marks correct)
     *   - Wrong answer (dash marks incorrect)
     *   > Optional explanation shown after answering
     *
     * Add 'score' after quiz to include in scoring: ```quiz score
     * Multiple correct answers = checkboxes, single correct = radio buttons
     */
    let convertQuizBlocks = function (markdown) {
        // First process quiz-config blocks
        markdown = convertQuizConfig(markdown);

        let quizRegex = /`{3,}quiz(\s+score)?\s*\n([\s\S]*?)`{3,}/g;
        let quizId = 0;
        let scoredQuizCount = 0;

        let result = markdown.replace(quizRegex, function (match, scoreFlag, content) {
            let html = '';
            let isScored = scoreFlag && scoreFlag.trim() === 'score';
            let lines = content.trim().split('\n');
            let currentQuestion = null;
            let questions = [];

            // Parse quiz content
            for (let i = 0; i < lines.length; i++) {
                let line = lines[i].trim();

                if (line.match(/^Q:\s*/i)) {
                    // New question
                    if (currentQuestion) {
                        questions.push(currentQuestion);
                    }
                    currentQuestion = {
                        text: line.replace(/^Q:\s*/i, ''),
                        options: [],
                        explanation: null
                    };
                } else if (line.match(/^\*\s+/)) {
                    // Correct answer
                    if (currentQuestion) {
                        currentQuestion.options.push({
                            text: line.replace(/^\*\s+/, ''),
                            correct: true
                        });
                    }
                } else if (line.match(/^-\s+/)) {
                    // Incorrect answer
                    if (currentQuestion) {
                        currentQuestion.options.push({
                            text: line.replace(/^-\s+/, ''),
                            correct: false
                        });
                    }
                } else if (line.match(/^>\s*/)) {
                    // Explanation
                    if (currentQuestion) {
                        currentQuestion.explanation = line.replace(/^>\s*/, '');
                    }
                }
            }

            // Don't forget the last question
            if (currentQuestion) {
                questions.push(currentQuestion);
            }

            // Generate HTML for each question
            questions.forEach(function (q, qIndex) {
                let qId = 'quiz-' + quizId + '-q' + qIndex;
                let correctCount = q.options.filter(o => o.correct).length;
                let inputType = correctCount > 1 ? 'checkbox' : 'radio';
                let inputName = qId + '-options';

                if (isScored) {
                    scoredQuizCount++;
                }

                html += '<div class="ll-quiz' + (isScored ? ' ll-quiz-scored' : '') + '" data-quiz-id="' + qId + '" data-scored="' + isScored + '" data-answered="false" data-correct="false">';

                // Add header with score display for scored quizzes
                if (isScored) {
                    html += '<div class="ll-quiz-header"><span class="ll-quiz-badge-label">Scored Quiz</span><span class="ll-quiz-score-display"></span></div>';
                }

                html += '<div class="ll-quiz-question">' + q.text + '</div>';
                html += '<div class="ll-quiz-options">';

                q.options.forEach(function (opt, optIndex) {
                    let optId = qId + '-opt' + optIndex;
                    html += '<label class="ll-quiz-option" data-correct="' + opt.correct + '">';
                    html += '<input type="' + inputType + '" name="' + inputName + '" id="' + optId + '" value="' + optIndex + '">';
                    html += '<span class="ll-quiz-option-text">' + opt.text + '</span>';
                    html += '<span class="ll-quiz-feedback"></span>';
                    html += '</label>';
                });

                html += '</div>';

                if (q.explanation) {
                    html += '<div class="ll-quiz-explanation" style="display:none;">' + q.explanation + '</div>';
                }

                html += '<button type="button" class="ll-quiz-check" onclick="checkQuizAnswer(\'' + qId + '\', ' + (inputType === 'checkbox') + ')">Check Answer</button>';
                html += '<button type="button" class="ll-quiz-retry" style="display:none;" onclick="retryQuiz(\'' + qId + '\')">Try Again</button>';
                html += '<div class="ll-quiz-result"></div>';
                html += '</div>';

                quizId++;
            });

            return html;
        });

        // If there are scored quizzes, add a hidden tracker for state and badge container
        if (scoredQuizCount > 0) {
            result += '<div id="ll-quiz-score-tracker" data-total="' + scoredQuizCount + '" data-correct="0" data-answered="0">';
            result += '<div class="ll-quiz-badge-container" style="display:none;"></div>';
            result += '</div>';
        }

        return result;
    }

    // DBDOC-2575: Add ability to expand images to full screen
    let addModalWindow = function (articleElement) {
        let modalClose = $(document.createElement('span')).attr('id', 'modalClose').html("&times;");
        let modalImg = $(document.createElement('img')).attr('id', 'modalImg');
        let modalCaption = $(document.createElement('div')).attr('id', 'modalCaption');
        let modalWindow = $(document.createElement('div')).attr('id', 'modalWindow');

        $(modalWindow).append([modalCaption, modalClose, modalImg]);
        $(articleElement).append(modalWindow);

        $(articleElement).find('img').click(function () {
            $(modalImg).attr({ src: this.src, alt: this.alt });
            $(modalWindow).addClass('show');
            $(modalCaption).text(this.alt);
        })
        $(modalWindow).click(function () {
            $(modalWindow).removeClass('show');
        })

        return articleElement;
    }

    // DBDOC-2455: Support for content selectable via tabs
    let showTabs = function (articleElement, type) {
        if ($.type(type) == "object") { // if true, it means select tab needs to be added
            let div = $(document.createElement('div')).addClass('selection_tabs');
            let tab = $(document.createElement('ul')).addClass('tab');

            if (getParam("type") == false) {
                window.history.pushState('', '', setParam(window.location.href, 'type', Object.keys(type)[0]));
            }

            $(Object.keys(type)).each(function (_, type_key) {
                let li = $(document.createElement('li')).addClass('btn_if_' + type_key);
                // $(li).html('<a href="' + setParam(window.location.href, 'type', type_key) + '">' + type[type_key] + '</a>');
                $(li).html('<a href="#">' + type[type_key] + '</a>');
                $(li).find('a').click(function () {
                    $(this).attr('href', setParam(window.location.href, 'type', type_key));
                });
                $(tab).append(li);

                if (type_key == getParam("type")) {
                    $(li).find('a').addClass('active');
                }
            });

            $(div).append(tab);
            $(articleElement).find('h2:not(:eq(0))').after(div);
            $(articleElement).find('h1').after(div);
            $(articleElement).find('.selection_tabs:not(:eq(0))').addClass('stick');
        }

        return articleElement;
    }
    // DBDOC-2494: added for syntax highlight feature. The syntax highlight feature uses the highlight.js plugin.
    let highlightCodeBlock = function (articleElement) {
        $(articleElement).find('pre:not(.nohighlighting) code').each(function (_, block) {
            hljs.highlightBlock(block);
        });
        return articleElement;
    }

    // DBDOC-2449: added for force download feature. To force download a file referenced in the link, append '?download=1' to the link.
    let enableForceDownload = function (articleElement) {
        $(articleElement).find('a[href$="?download=1"]').each(function () { // loop through each link that ends with ?download=1
            $(this).attr('download', ''); // set download attribute to the link
            $(this)[0].href = $(this)[0].href.replace('?download=1', ''); // removes ?download=1 from the link
        });
        return articleElement;
    }

    // added for include feature: [DBDOC-2434] Include any file inside of Markdown before rendering
    let include = function (markdown, include) {
        for (let short_name in include) {
            if (typeof include[short_name] !== 'object')
                continue;
            include[short_name]['content'] = addPathToImageSrc(include[short_name]['content'], include[short_name]['path']);
            // console.log("include function: " ,include[short_name]['path'] );
            markdown = markdown.split("[](include:" + short_name + ")").join(include[short_name]['content']);
        }
        return markdown;
    }

    // added for variable substitute feature
    let substituteVariables = function (markdown, all_variables) {
        for (let variable in all_variables) {
            markdown = markdown.split("[](var:" + variable + ")").join(all_variables[variable]);
        }
        return markdown;
    }

    /**
     * Calculates estimated reading time and replaces "Estimated Time: X" or "Estimated Time: x"
     * Only replaces if the pattern contains exactly X or x as placeholder
     * @param {string} markdown - The markdown content
     * @returns {string} - Markdown with calculated time replacing placeholder
     */
    let calculateEstimatedTime = function (markdown) {
        // Only match exactly "Estimated Time: X" or "Estimated Time: x"
        // Use [ \t]* instead of \s* to avoid consuming newlines
        const placeholderPattern = /Estimated Time:[ \t]*([Xx])[ \t]*(?:minutes?)?/;
        const match = markdown.match(placeholderPattern);

        // If no placeholder found, return unchanged
        if (!match) {
            return markdown;
        }

        // Extract code blocks first (to count separately)
        const codeBlockPattern = /```[\s\S]*?```/g;
        const codeBlocks = markdown.match(codeBlockPattern) || [];

        // Remove code blocks from markdown for regular word count
        let textContent = markdown.replace(codeBlockPattern, '');

        // Count images
        const imagePattern = /!\[.*?\]\(.*?\)/g;
        const imageCount = (markdown.match(imagePattern) || []).length;

        // Remove markdown syntax for cleaner word count
        textContent = textContent
            .replace(/!\[.*?\]\(.*?\)/g, '')           // Remove images
            .replace(/\[.*?\]\(.*?\)/g, '')            // Remove links
            .replace(/#{1,6}\s*/g, '')                 // Remove headers
            .replace(/[*_`~]/g, '')                    // Remove formatting
            .replace(/<[^>]+>/g, '')                   // Remove HTML tags
            .replace(/\|/g, ' ')                       // Replace table pipes
            .replace(/[-=]{3,}/g, '');                 // Remove horizontal rules

        // Count words in regular text
        const textWords = textContent.split(/\s+/).filter(word => word.length > 0).length;

        // Count words in code blocks
        let codeWords = 0;
        codeBlocks.forEach(block => {
            const codeContent = block.replace(/```\w*\n?/g, '').replace(/```/g, '');
            codeWords += codeContent.split(/\s+/).filter(word => word.length > 0).length;
        });

        // Calculate reading time
        // Text: 225 words per minute (middle of 200-250)
        // Code: 200 words per minute (10% slower)
        // Images: 12 seconds each
        const textMinutes = textWords / 225;
        const codeMinutes = codeWords / 200;
        const imageMinutes = (imageCount * 12) / 60;

        // Total time with 10% added for hands-on instructions
        let totalMinutes = (textMinutes + codeMinutes + imageMinutes) * 1.10;

        // Round up to next 5-minute increment
        totalMinutes = Math.ceil(totalMinutes / 5) * 5;

        // Ensure minimum of 5 minutes
        if (totalMinutes < 5) {
            totalMinutes = 5;
        }

        // Replace the placeholder with calculated time
        markdown = markdown.replace(placeholderPattern, 'Estimated Time: ' + totalMinutes + ' minutes');

        console.log('Estimated Time calculated:', totalMinutes, 'minutes (text:', textWords, 'words, code:', codeWords, 'words, images:', imageCount + ')');

        return markdown;
    }

    let addPathToTypeHrefs = function (markdown) {
        let regex_type = new RegExp(/\[(?:.+?)\]\((&type=(\S*?))\)/g);
        let matches;

        do {
            matches = regex_type.exec(markdown);
            if (matches !== null) {
                markdown = markdown.replace(matches[1], setParam(window.location.href, "type", matches[2]));
            }
        } while (matches);

        return markdown;
    }

    let arrowClick = function () {
        if ($(this).text() === '-') {
            $(this).next().next().fadeOut('fast', function () {
                $(window).scroll();
            });
            $(this).text('+');
        } else {
            $(this).next().next().fadeIn('fast', function () {
                $(window).scroll();
            });
            $(this).text('-');
        }
    }

    let setupRelatedSection = function (manifestFileContent) {
        // this part has been added for LLAPEX-448
        const max_related = 5;
        let related_li = [];
        if ('show_related' in manifestFileContent) {
            let related_content;
            let tut_titles = [];

            for (let i = 0; i < manifestFileContent.tutorials.length; i++) {
                tut_titles[i] = manifestFileContent.tutorials[i].title.toLowerCase();
            }

            for (let i = 0; i < manifestFileContent.show_related.length; i++) {
                if (!('filename' in manifestFileContent.show_related[i]) || !('tags' in manifestFileContent.show_related[i]) || !('title' in manifestFileContent.show_related[i])) {
                    continue;
                }
                $.getJSON(related_path + manifestFileContent.show_related[i]['filename'], function (content) {
                    related_content = content;
                }).done(function () {
                    related_li[i] = $(document.createElement('li')).attr('id', 'related-content-' + i).css({ 'border-bottom': '0px', 'padding-left': '36px', 'cursor': 'default', 'background-color': 'rgb(0,0,0,0.06)' });

                    let div_main = $(document.createElement('div'));
                    let a = $(document.createElement('a')).css('cursor', 'pointer');
                    let arrow, div;

                    $(a).click(function () {
                        $(this).prev().click();
                    });
                    $(a).append($(document.createElement('div')).text(manifestFileContent.show_related[i]['title']).css({ 'font-weight': '600' }));
                    $(div_main).append(a);
                    $(related_li[i]).append(div_main);
                    div = $(document.createElement('div')).attr('id', 'toc-related-' + i).addClass('toc');
                    $(div_main).append(div);

                    if ('state' in manifestFileContent.show_related[i] && manifestFileContent.show_related[i]['state'] === "collapsed") {
                        $(div).hide();
                        arrow = $(document.createElement('div')).addClass('arrow').text('+');
                    } else {
                        arrow = $(document.createElement('div')).addClass('arrow').text('-');
                    }

                    $(arrow).css('cursor', 'pointer').click(arrowClick);
                    $(div_main).prepend(arrow);
                    $("#leftNav-toc ul.hol-Nav-list:first-of-type").append(related_li[i]);

                    // for each related workshop
                    let related_workshops = {};
                    let tags = manifestFileContent.show_related[i]['tags'];
                    $(tags).each(function (_, tag) {
                        related_workshops = { ...related_workshops, ...related_content[tag] };
                    });

                    let filtered_workshops = {};

                    for (let j = 0; j < Object.keys(related_workshops).length; j++) {
                        if (manifestFileContent.workshoptitle.toLowerCase() === Object.keys(related_workshops)[j].toLowerCase()) continue;
                        if ($.inArray(Object.keys(related_workshops)[j].toLowerCase(), tut_titles) != -1) continue;

                        filtered_workshops[Object.keys(related_workshops)[j]] = related_workshops[Object.keys(related_workshops)[j]];
                    }

                    let filter = Object.keys(filtered_workshops).sort(() => Math.random() - Math.random()).slice(0, max_related);

                    $(filter).each(function (_, f) {
                        let ul = document.createElement('ul');
                        let li = $(document.createElement('li')).addClass('toc-item').text(f);
                        $(li).wrapInner('<a href="' + filtered_workshops[f] + '"></a>');
                        $(ul).append(li);
                        $(ul).appendTo(div);
                    });
                });
            }
        }
    }
    let prepareToc = function (manifestFileContent) {
        let h2_regex = new RegExp(/^##\s(.+)*/gm);
        let h2s_list = [];
        let matches;
        let tut_fname;

        // const currentDomain = window.location.origin; // e.g., "https://livelabs.oracle.com"

        $(manifestFileContent.tutorials).each(function (i, tutorial) {
            let ul;
            let div = document.createElement('div');
            $(div).attr('id', 'toc' + i).addClass('toc');

            // Modify tut_fname based on the current domain
            if (tutorial.filename.startsWith("/") && currentDomain.includes("livelabs.oracle.com")) {
                tut_fname = "/cdn/" + tutorial.filename.replace(/^\/+/, ""); // Ensure correct path
            } else if (tutorial.filename.startsWith("/") && currentDomain.includes("apexapps-stage.oracle.com")) {
                tut_fname = "/livelabs/cdn/" + tutorial.filename.replace(/^\/+/, ""); // Ensure correct path
            } else {
                tut_fname = tutorial.filename;
            }

            $.get(tut_fname, function (markdownContent) { //reading MD file in the manifest and storing content in markdownContent variable
                if (tutorial.filename == 'preview' && markdownContent == "None") {
                    markdownContent = window.localStorage.getItem("mdValue");
                }
                markdownContent = include(markdownContent, manifestFileContent.include);
                markdownContent = singlesource(markdownContent, tutorial.type);

                do {
                    matches = h2_regex.exec(markdownContent);

                    if (matches !== null) {
                        ul = document.createElement('ul');
                        $(ul).append($(document.createElement('li')).addClass('toc-item').text(matches[1].replace(/\**/g, '').replace(/\##/g, '')).attr('data-unique', alphaNumOnly(matches[1])));
                        $(ul).click(function () {
                            if ($(this).parent().parent().parent().hasClass('selected')) {
                                location.hash = alphaNumOnly($(this).text());
                                expandSectionBasedOnHash($(this).find('li').attr('data-unique'));
                            } else {
                                changeTutorial(getMDFileName(tutorial.filename), alphaNumOnly($(this).text()));
                            }

                        });

                        // fix added for LLAPEX-400
                        $(ul).each(function () {
                            if (tutorial !== selectTutorial(manifestFileContent)) {
                                let li = $(this).find('li')[0];
                                $(li).wrapInner('<a href="' + unescape(setParam(window.location.href, queryParam, getMDFileName(tutorial.filename))) + '#' + $(li).attr('data-unique') + '"></a>');
                            }
                        });
                        $(ul).appendTo(div);
                    }
                } while (matches);

            });

            $('.hol-Nav-list li')[i].append(div);
        });

        setTimeout(function () {
            let anchorItem = $('.selected li[data-unique="' + location.hash.slice(1) + '"]');
            if (anchorItem.length !== 0)
                $(anchorItem)[0].click();
        }, 1000);
        $(".hol-Nav-list>li").wrapInner("<div></div>")

        $(".hol-Nav-list>li>div").prepend($(document.createElement('div')).addClass('arrow').text('+'));

        $('.hol-Nav-list > li > div .arrow').click(arrowClick);

        $('.selected div.arrow').text('-');
        $('.hol-Nav-list > li:not(.selected) .toc').hide();

    }

    let toggleTutorialNav = function () {
        let nav_param = getParam(nav_param_name);

        if (!nav_param || nav_param === 'open') {
            $('.hol-Nav-list > li:not(.selected)').attr('tabindex', '0');
            $('#leftNav-toc, #leftNav, #contentBox').addClass('open').removeClass('close');
        } else if (nav_param === 'close') {
            $('.hol-Nav-list > li:not(.selected)').attr('tabindex', '-1');
            $('#leftNav-toc, #leftNav, #contentBox').addClass('close').removeClass('open');
        }
        setTimeout(function () {
            $(window).scroll();
        }, 100);
    }

    /*
     * ============================================
     * SECTION 4: NAVIGATION
     * ============================================
     */

    /**
     * Creates and populates the tutorial navigation sidebar
     * @param {Object} manifestFileContent - The manifest file content
     * @returns {Object} The selected tutorial object
     */
    const setupTutorialNav = function (manifestFileContent) {
        let div = $(document.createElement('div')).attr('id', 'leftNav-toc');
        let ul = $(document.createElement('ul')).addClass('hol-Nav-list');

        $(manifestFileContent.tutorials).each(function (i, tutorial) {
            let file_name = getMDFileName(tutorial.filename);

            $(document.createElement('li')).each(function () {
                $(this).click(function (e) {
                    if (!$(e.target).hasClass('arrow') && !$(e.target).hasClass('toc-item') && !$(e.target).hasClass('toc-item active')) {
                        if ($(e.target).parent().parent().hasClass('selected') || $(e.target).hasClass('selected')) {
                            try {
                                $('.selected .arrow').click();
                            } catch (err) { console.debug('Nav click error:', err); }
                        } else {
                            changeTutorial(file_name);
                        }
                    }
                });
                $(this).attr('id', getLabNavID(file_name));
                //The title specified in the manifest appears in the side nav as navigation
                // $(this).text(tutorial.title).wrapInner("<span></span>");
                $(this).text(tutorial.title).wrapInner("<a href=\"" + unescape(setParam(window.location.href, queryParam, getMDFileName(tutorial.filename))) + "\"><div></div></a>");
                $(this).appendTo(ul);

                /* for accessibility */
                $(this).keydown(function (e) {
                    if (e.keyCode === 13 || e.keyCode === 32) { //means enter and space
                        e.preventDefault();
                        changeTutorial(file_name);
                    }
                });
                /* accessibility code ends here */
            });
        });

        $(ul).appendTo(div);
        $(div).appendTo('#leftNav');
        return selectTutorial(manifestFileContent);
    }

    let getMDFileName = function (file_name) {
        return file_name.split('/')[file_name.split('/').length - 1].replace('.md', '');
    }

    let getLabNavID = function (file_name, prefix = 'tut-') {
        return prefix + getMDFileName(file_name.toString()).replace(/[\(\)]+?/g, '').replace('.md', '');
    }

    let selectTutorial = function (manifestFileContent, position = 0) {
        $('#' + getLabNavID(getParam(queryParam))).addClass('selected'); //add class selected to the tutorial that is selected by using the ID
        $('.selected').find('a').contents().unwrap(); // remove hyperlink from "selected" lab
        $('.selected').unbind('keydown');

        if (position === -2) return manifestFileContent.tutorials[0];
        if (position === 2) return manifestFileContent.tutorials[manifestFileContent.tutorials.length - 1];

        //find which tutorial in the manifest file is selected
        for (var i = 0; i < manifestFileContent.tutorials.length; i++) {
            if (getParam(queryParam) === getMDFileName(manifestFileContent.tutorials[i].filename))
                return manifestFileContent.tutorials[i + position];
        }

        // if old link style URL is used (for example: ?labs=short-tutorial-title)
        // remove this condition after old style link is removed
        for (var i = 0; i < manifestFileContent.tutorials.length; i++) {
            if (getParam(queryParam) === createShortNameFromTitle(manifestFileContent.tutorials[i].title)) {
                changeTutorial(getMDFileName(manifestFileContent.tutorials[i].filename), window.location.hash.substr(1));
                return;
            }
        }
        // until here

        //if no title has selected class, selected class is added to the first class
        $('.hol-Nav-list').find('li:eq(0)').addClass("selected");
        return manifestFileContent.tutorials[0 + position]; //return the first tutorial is no tutorial is matches
    }

    /* Setup toc navigation and tocify */
    let setupTocNav = function () {
        $(".hol-Nav-list .selected").wrapInner("<div tabindex='0'></div>")
        $(".hol-Nav-list .selected div").prepend($(document.createElement('div')).addClass('arrow').text('+'));
        $(".hol-Nav-list .selected").unbind('click');

        $(".hol-Nav-list .selected > div").click(function (e) {
            if ($('.selected div.arrow').text() === '-') {
                $('#toc').fadeOut('fast');
                $('.selected div.arrow').text('+');
            } else {
                $('#toc').fadeIn('fast');
                $('.selected div.arrow').text('-');
            }
        });

        /* for accessibility */
        $(".hol-Nav-list .selected > div").keydown(function (e) {
            if (e.keyCode === 13 || e.keyCode === 32) { //means enter and space
                e.preventDefault();
                $(this).click()
            }
        });
        /* accessibility code ends here */

        $(window).scroll();
        $('#toc').appendTo(".hol-Nav-list .selected");
        $('.selected div.arrow').click();
    }
    
    /* The following function performs the event that must happen when the lab links in the navigation is clicked */
    let changeTutorial = function (file_name, anchor = "") {

        if (anchor !== "") anchor = '#' + anchor;
        location.href = unescape(setParam(window.location.href, queryParam, file_name) + anchor);
    }

    /*the following function changes the path of images as per the path of the MD file.
    This ensures that the images are picked up from the same location as the MD file.
    The manifest file can be in any location.*/
    let addPathToImageSrc = function (markdownContent, myUrl) {
        let imagesRegExp = new RegExp(/!\[.*?\]\((.*?)\)/g);
        let contentToReplace = []; // content that needs to be replaced
        let matches;

        myUrl = myUrl.substring(0, myUrl.lastIndexOf('/') + 1); //removing filename from the url

        do {
            matches = imagesRegExp.exec(markdownContent);
            // console.log(matches);
            if (matches === null) {
                $(contentToReplace).each(function (index, value) {
                    markdownContent = markdownContent.replace(value.replace, value.with);
                });
                return markdownContent;
            }

            // if (myUrl.indexOf("/") !== 1) {
            matches[1] = matches[1].split(' ')[0];
            let origImg = matches[1].trim();
            if (matches[1].indexOf("http") === -1 && matches[1][0] !== "/") {
                contentToReplace.push({
                    "replace": '(' + matches[1],
                    /* "with": '(' + myUrl + matches[1] TMM: changed 10/6/20*/
                    "with": '(' + myUrl + matches[1].trim()
                });
            }

            if (["livelabs.oracle.com", "apexapps-stage.oracle.com"].some(domain => currentDomain.includes(domain))
            && !origImg.startsWith("/cdn/") && !origImg.startsWith("/livelabs/cdn/") && origImg.startsWith("/")) {
                let replaceImg = origImg; // Default to the original path
            
                if (currentDomain.includes("livelabs.oracle.com")) {
                    replaceImg = "/cdn" + origImg;
                } else if (currentDomain.includes("apexapps-stage.oracle.com")) {
                    replaceImg = "/livelabs/cdn" + origImg;
                }
                    
                contentToReplace.push({
                    replace: `(${origImg}`,
                    with: `(${replaceImg}`
                });
                
            }
            
        } while (matches);
    }
    /* The following function adds the h1 title before the container div. It picks up the h1 value from the MD file. */
    let updateH1Title = function (articleElement) {
        $('#tutorial-title').text("\t\t›\t\t" + $(articleElement).find('h1').text());
        // $(articleElement).find('h1').remove(); //Removing h1 from the articleElement as it has been added to the HTML file already
        return articleElement;
    }
    /* This function picks up the entire converted content in HTML, and break them into sections. */
    let wrapSectionTag = function (articleElement) {
        $(articleElement).find('h2').each(function () {
            $(this).nextUntil('h2').andSelf().wrapAll('<section></section>');
        });
        return articleElement;
    }
    /* Wrapping all images in the article element with Title in the MD, with figure tags, and adding figcaption dynamically.
    The figcaption is in the format Description of illustration [filename].
    The image description files must be added inside the files folder in the same location as the MD file.*/
    let wrapImgWithFigure = function (articleElement) {
        // Add lazy loading attribute to images
        // First image loads eagerly (above the fold), rest load lazily
        let isFirstImage = true;
        $(articleElement).find("img").each(function () {
            if (isFirstImage) {
                isFirstImage = false;
                $(this).attr('loading', 'eager');
            } else {
                $(this).attr('loading', 'lazy');
            }
        });

        $(articleElement).find("img").on('load', function () {
            if ($(this)[0].width > 100 || $(this)[0].height > 100 || $(this).attr("title") !== undefined) { // only images with title or width or height > 100 get wrapped (DBDOC-2397)
                $(this).wrap("<figure></figure>"); //wrapping image tags with figure tags

            }

            //Add role attribute to all images that do not have an alt attribute
            if ($(this).attr("alt").length < 1 || (!$(this).attr("alt")) || $(this).attr("alt") == '' || $(this).attr("alt") == undefined || $(this).attr("alt") == 0) {
                // $(this).attr("role","presentation"); ALternative solution
                $(this).attr("alt", "The content is described above.");
            }

        });
        return articleElement;
    }
    /*the following function changes the path of the HREFs based on the absolute path of the MD file.
    This ensures that the files are linked correctly from the same location as the MD file.
    The manifest file can be in any location.*/
    let addPathToAllRelativeHref = function (articleElement, myUrl) {
        if (myUrl.indexOf("/") !== -1) {
            myUrl = myUrl.replace(/\/[^\/]+$/, "/"); //removing filename from the url
            $(articleElement).find('a').each(function () {
                if ($(this).attr("href").indexOf("http") === -1 && $(this).attr("href")[0] !== "/" && $(this).attr("href").indexOf("?") !== 0 && $(this).attr("href").indexOf("#") !== 0) {
                    $(this).attr("href", myUrl + $(this).attr("href"));
                }
            });
        }
        return articleElement;
    }
    /* the following function makes anchor links work by adding an event to all href="#...." */
    let makeAnchorLinksWork = function (articleElement) {
        $(articleElement).find('a[href^="#"]').each(function () {
            let href = $(this).attr('href');
            if (href !== "#") { //eliminating all plain # links
                $(this).click(function () {
                    expandSectionBasedOnHash(href.split('#')[1]);
                });
            }
        });
        return articleElement;
    }
    /*the following function sets target for all HREFs to _blank */
    let addTargetBlank = function (articleElement) {
        $(articleElement).find('a').each(function () {
            if ($(this).attr('href').indexOf("http") === 0 && $(this).attr('href').indexOf("&type=") == -1) //ignoring # hrefs
                $(this).attr('target', '_blank'); //setting target for ahrefs to _blank
        });
        return articleElement;
    }
    /* Sets the title, contentid, description, partnumber, and publisheddate attributes in the HTML page.
    The content is picked up from the manifest file entry*/
    let updateHeadContent = function (tutorialEntryInManifest, workshoptitle) {
        (workshoptitle !== undefined) ?
            document.title = workshoptitle + " | " + tutorialEntryInManifest.title :
            document.title = tutorialEntryInManifest.title;

        const metaProperties = [{
            name: "contentid",
            content: tutorialEntryInManifest.contentid
        }, {
            name: "description",
            content: tutorialEntryInManifest.description
        }, {
            name: "partnumber",
            content: tutorialEntryInManifest.partnumber
        }, {
            name: "publisheddate",
            content: tutorialEntryInManifest.publisheddate
        }];
        $(metaProperties).each(function (i, metaProp) {
            if (metaProp.content) {
                let metaTag = document.createElement('meta');
                $(metaTag).attr(metaProp).prependTo('head');
            }
        });
    }

    /* Add the Go to forum link in the footer (DBDOC-2459 and DBDOC-2496) */
    let addGoToForumLink = function (support) {
        const support_text = "Go to forum";
        if (support !== undefined) {
            // the Need Help? URL is taken from the manifest file (key is support)
            let need_help = $(document.createElement('li')).append($(document.createElement('a')).attr({ 'href': support, 'target': '_blank' }).text(support_text));
            $('.footer-links').append(need_help);
        }
    }

    /* Add the Need Help link in the header (DBDOC-2459 and DBDOC-2496) */
    let addNeedHelpLink = function (help, wtitle) {
        const subject = "Question about workshop: " + wtitle;
        const help_text = "Need help? Send us an email.";
        if (help !== undefined) {
            // the Need Help? URL is taken from the manifest file (key is help)
            let need_help = $(document.createElement('a')).attr({ 'href': 'mailto:' + help + '?subject=' + subject, 'title': help_text, 'id': 'need_help', 'tabindex': '0' }).text('?').addClass('header-icon');
            $('header .hol-Header-wrap').append(need_help);

            // let need_help_div = $(document.createElement('div')).attr({ 'href': 'mailto:' + help + '?subject=' + subject, 'title': help_text, 'id': 'need_help', 'tabindex': '0' }).text('?');
            // $('div#container').append(need_help_div);
        }
    }
    let addTranslateIcon = function (help) {
        const help_text = "Need another language? Learn how to translate this page?";
    
        if (help !== undefined) {
            let translate_icon = $('<a>', {
                href: '#',
                title: help_text,
                id: 'translate_icon',
                tabindex: '0'
            }).html(`
                <svg xmlns="http://www.w3.org/2000/svg" shape-rendering="geometricPrecision" text-rendering="geometricPrecision" image-rendering="optimizeQuality" fill-rule="evenodd" clip-rule="evenodd" viewBox="0 0 512 511.997"><path fill="#fff" fill-rule="nonzero" d="M456.103 372.929c.76 0 1.503.076 2.221.22 18.883-32.877 29.294-67.765 30.989-105.931h-70.387c-1.273 35.725-11.943 70.959-31.822 105.711h68.999zm-12.274 22.439h-70.885c-21.522 31.176-50.508 61.962-86.825 92.362 62.484-7.736 120.355-41.731 157.71-92.362zM225.876 487.73c-36.317-30.401-65.302-61.187-86.824-92.362H68.171c37.351 50.625 95.219 84.622 157.705 92.362zM53.549 372.929h71.343c-19.881-34.752-30.548-69.986-31.822-105.711H22.687c1.692 38.09 12.06 72.896 30.862 105.711zM22.687 244.778h70.82c2.607-35.001 14.22-70.236 35.03-105.71H53.549c-18.805 32.824-29.17 67.626-30.862 105.71zm45.484-128.15h74.743c21.286-30.671 49.426-61.521 84.54-92.551-63.108 7.382-121.587 41.459-159.283 92.551zM284.54 24.077c35.114 31.03 63.256 61.878 84.542 92.551h74.746c-37.692-51.087-96.176-85.172-159.288-92.551zm173.91 114.991h-74.99c20.812 35.473 32.424 70.709 35.03 105.71h70.823c-1.692-38.095-12.061-72.891-30.863-105.71zM256 0c85.059 0 164.712 41.638 212.305 112.556C497.103 155.464 512 203.909 512 256c0 52.06-14.832 100.437-43.695 143.441C420.677 470.412 341.002 511.997 256 511.997c-85.06 0-164.713-41.638-212.306-112.556C14.897 356.535 0 308.089 0 256c0-52.063 14.83-100.439 43.694-143.444C91.322 41.585 170.997 0 256 0zm11.218 38.617v78.011h74.275c-19.514-25.73-44.246-51.733-74.275-78.011zm0 100.451v105.71h128.845c-2.917-34.714-15.788-69.947-38.83-105.71h-90.015zm0 128.15v105.711h93.793c22.204-34.986 34.125-70.221 35.547-105.711h-129.34zm0 128.15v78.971c31.859-26.182 57.931-52.505 78.111-78.971h-78.111zm-22.439 78.976v-78.976h-78.112c20.182 26.467 46.25 52.792 78.112 78.976zm0-101.415V267.218h-129.34c1.421 35.49 13.34 70.725 35.547 105.711h93.793zm0-128.151v-105.71h-90.015c-23.04 35.763-35.913 70.996-38.83 105.71h128.845zm0-128.15V38.609c-30.032 26.281-54.763 52.286-74.275 78.019h74.275z"/></svg>
                `)                
                .addClass('header-icon');
    
            translate_icon.on('click', function (e) {
                e.preventDefault();
                $('#translate_popup').toggle();
            });

            // Detect browser
            let userAgent = navigator.userAgent.toLowerCase();
            let defaultTab = 'chrome'; // fallback
            if (userAgent.includes('edg')) {
                defaultTab = 'edge';
            } else if (userAgent.includes('firefox')) {
                defaultTab = 'firefox';
            } else if (userAgent.includes('safari') && !userAgent.includes('chrome') && !userAgent.includes('edg')) {
                defaultTab = 'safari';
            } else if (userAgent.includes('chrome') && !userAgent.includes('edg')) {
                defaultTab = 'chrome';
            }
    
            let popupContent = `<div class="translation-popup-content">
    <h2>How to Translate This Page</h2>
    <p>You must be on the <strong>livelabs.oracle.com</strong> domain to use translations.<br>
       They are not available on <em>apexapps.oracle.com</em>.</p>
    <p>For the best translation experience, we recommend <strong>Google Chrome</strong>.</p>

    <!-- Tabs -->
    <div class="translation-tabs">
        <button class="tab active" data-tab="chrome">Google Chrome</button>
        <button class="tab" data-tab="safari">Safari</button>
        <button class="tab" data-tab="edge">Microsoft Edge</button>
        <button class="tab" data-tab="firefox">Firefox</button>
    </div>

    <!-- Chrome Instructions -->
    <div class="tab-content" id="chrome">
        <ol>            
            <li><strong>Right-click</strong> anywhere on the page and choose <em>“Translate to <br>[Your Language]”</em>.</li>
            <li>If that option doesn’t appear, click the <strong>⋮ three-dot menu</strong> in the <br> top-right corner of Chrome.</li>
            <li>Select <em>“Translate”</em> from the dropdown.</li>
            <li>
                Then, click the <strong>translate icon</strong>
                <img 
                    src="https://oracle-livelabs.github.io/common/redwood-hol/img/translate-icon-chrome.png" 
                    alt="Translate icon" 
                    style="height: 30px; vertical-align: middle; margin-left: 4px;" 
                    referrerpolicy="no-referrer"
                > in the address bar.
            </li>
            <li>If needed, click the <strong>⋮ three-dot menu</strong> within the Google <br>Translate popup and choose your preferred language.</li>
        </ol>
    </div>

    <!-- Safari Instructions -->
    <div class="tab-content" id="safari" style="display: none;">
        <ol>
            <li>
                Click the <strong>translate icon</strong>
                <img 
                    src="https://oracle-livelabs.github.io/common/redwood-hol/img/translate-icon-safari.png" 
                    alt="Translate icon" 
                    style="height: 30px; vertical-align: middle; margin-left: 4px;" 
                    referrerpolicy="no-referrer"
                > in the Safari address bar.
            </li>
            <li>If the icon doesn’t appear, use the menu bar at the top of your <br> screen (next to the Apple  icon).</li>
            <li>Select <strong>View</strong> → <strong>Translation</strong> → <br><em>“Translate to [Your Language]”</em>.</li>
            <li>
                If no translation languages are available, click <strong>Preferred <br>Languages</strong> in the prompt and follow these steps:
                <ol type="a">
                    <li>System Settings will open to <strong>Language & Region</strong>.</li>
                    <li>Click the <strong>+</strong> button under Preferred Languages, <br>add your desired language, and close Settings.</li>
                    <li>Return to Safari and repeat step 2 to translate the page.</li>
                </ol>
            </li>
        </ol>
    </div>

    <!-- Edge Instructions -->
    <div class="tab-content" id="edge" style="display: none;">
        <ol>
            <li><a href="${window.location.href}" target="_blank">Click here to open this workshop in a new tab.</a></li>
            <li>Right-click anywhere on the page and select <em>“Translate to [Your<br> Language]”</em>.</li>
            <li>
                If necessary, click the <strong>translate icon</strong>
                <img 
                    src="https://oracle-livelabs.github.io/common/redwood-hol/img/translate-icon-edge.jpg" 
                    alt="Translate icon" 
                    style="height: 30px; vertical-align: middle; margin-left: 4px;" 
                    referrerpolicy="no-referrer"
                > in the Edge address<br> bar and select the desired language.
            </li>
            <li> Click the Translate button.</li>
            <li>If you navigate to a new lab and the translation disappears, <br> repeat steps 1 through 4 to re-enable it.</li>
        </ol>
    </div>

    <!-- Firefox Instructions -->
    <div class="tab-content" id="firefox" style="display: none;">
        <ol>
            Firefox Translations is still in beta and may not work on all pages.<br> For the most consistent experience, we recommend using <br>Chrome, Safari, or Edge.
        </ol>
    </div>
</div>
            `;



            // <div class="tab-content" id="firefox" style="display: none;">
            //     <ol>
            //         <li><a href="${window.location.href}" target="_blank">Click here to open this workshop in a new tab.</a></li>
            //         <li>In the new tab, click the <strong>☰ menu</strong> (three horizontal lines) in the<br> upper-right corner of Firefox.</li>
            //         <li>Select <em>“Translate Page”</em> from the dropdown menu.</li>
            //         <li>Then, choose the language you want to translate the page into.</li>
            //     </ol>
            //     <p><em>Note: Translation is only available in Firefox version 118 and above.<br> If you don’t see this option, make sure your browser is up to date.</em></p>
            // </div>
            // </div>

            let popup = $('<div>', {
                id: 'translate_popup'
            }).html(popupContent);
    
            $('header .hol-Header-wrap').append(translate_icon);
            $('body').append(popup);
    
            // After popup is appended, activate the default tab
            $(document).ready(function () {
                // Set default active tab
                $('.translation-tabs .tab').removeClass('active');
                $('.translation-tabs .tab[data-tab="' + defaultTab + '"]').addClass('active');
    
                $('.tab-content').hide();
                $('#' + defaultTab).show();
            });
    
            // Tab click behavior
            $(document).on('click', '.translation-tabs .tab', function () {
                const selectedTab = $(this).data('tab');
                $('.translation-tabs .tab').removeClass('active');
                $(this).addClass('active');
                $('.tab-content').hide();
                $('#' + selectedTab).show();
            });
        }
    };
    
    
    
    

    /* Add the Social Media link in the header */
    // let addSocialMediaLink = function(help, wtitle) {   
    //     let url_to_share = (window.location != window.parent.location) ? document.referrer: document.location.href; 
    //     console.log(url_to_share);
    //     console.log(window.parent.location);
    //     // Share Workshop on Facebook
    //     let fb = $(document.createElement('a')).attr({ 
    //         'href': 'https://facebook.com', 
    //         'title': "Share on Facebook", 
    //         'target': '_blank', 
    //         'id': 'need_help', 
    //         'tabindex': '1' 
    //     }).text('F');        
    //     $('header .hol-Header-wrap').append(fb);

    //     let linkedin = $(document.createElement('a')).attr({ 
    //         'href': 'https://linkedin.com', 
    //         'title': "Share on LinkedIn", 
    //         'target': '_blank', 
    //         'id': 'need_help', 
    //         'tabindex': '2' 
    //     }).text('I');        
    //     $('header .hol-Header-wrap').append(linkedin);

    //     let twitter = $(document.createElement('a')).attr({ 
    //         'href': 'https://twitter.com', 
    //         'title': "Share on Twitter", 
    //         'target': '_blank', 
    //         'id': 'need_help', 
    //         'tabindex': '2' 
    //     }).text('T');
    //     $('header .hol-Header-wrap').append(twitter);
    // }

    /*
     * ============================================
     * SECTION 5: UI COMPONENTS
     * ============================================
     */

    /**
     * Enables collapse/expand feature for the steps
     * @param {Object} manifestFileContent - The manifest file content
     * @param {HTMLElement} articleElement - The article element
     */
    const setupContentNav = function (manifestFileContent, articleElement) {
        //adds the expand collapse button before the second h2 element
        $("#module-content h2:eq(1)")
            .before('<button id="btn_toggle" class="hol-ToggleRegions plus">' + expandText + '</button>')
            .prev().on('click', function (e) {
                ($(this).text() === expandText) ? expandSection($("#module-content h2:not(:eq(0))"), "show") : collapseSection($("#module-content h2:not(:eq(0))"), "hide");
                changeButtonState(); //enables the expand all parts and collapse all parts button

            });
        //enables the feature that allows expand collapse of sections
        $("#module-content h2:not(:eq(0))").click(function (e) {
            ($(this).hasClass('plus')) ? expandSection(this, "fade") : collapseSection(this, "fade");
            changeButtonState();
        });
        /* for accessibility */
        $("#module-content h2:not(:eq(0))").attr('tabindex', '0');
        $('#module-content h2:not(:eq(0))').keydown(function (e) {
            if (e.keyCode === 13 || e.keyCode === 32) { //means enter and space
                e.preventDefault();
                if ($(this).hasClass('plus'))
                    expandSection($(this), "fade");
                else
                    collapseSection($(this), "fade");
            }
        });
        /* accessibility code ends here */

        // code to hide expand/collapse button
        let hide_expand_button = selectTutorial(manifestFileContent).hide_button || manifestFileContent.hide_button;
        if (hide_expand_button == "true" || hide_expand_button == "yes") {
            $('#btn_toggle').hide();
        }

        window.scrollTo(0, 0);
    }

    /**
     * Expands a collapsible section
     * @param {HTMLElement|jQuery} anchorElement - The anchor element (h2) to expand
     * @param {string} effect - Animation effect: "show", "fade", or "none"
     */
    const expandSection = function (anchorElement, effect) {
        if (effect === "show") {
            $(anchorElement).nextUntil("#module-content h1, #module-content h2").show('fast', function () {
                $(window).scroll();
            });
        } else if (effect === "fade") {
            $(anchorElement).nextUntil("#module-content h1, #module-content h2").fadeIn('fast', function () {
                $(window).scroll();
            });
        }
        $(anchorElement).addClass("minus");
        $(anchorElement).removeClass("plus");
    }

    /**
     * Collapses a collapsible section
     * @param {HTMLElement|jQuery} anchorElement - The anchor element (h2) to collapse
     * @param {string} effect - Animation effect: "hide", "fade", or "none"
     */
    const collapseSection = function (anchorElement, effect) {
        if (effect === "hide") {
            $(anchorElement).nextUntil("#module-content h1, #module-content h2").hide('fast', function () {
                $(window).scroll();
            });
        } else if (effect === "fade") {
            $(anchorElement).nextUntil("#module-content h1, #module-content h2").fadeOut('fast', function () {
                $(window).scroll();
            });
        } else if (effect === "none") {
            $(anchorElement).nextUntil("#module-content h1, #module-content h2").attr('style', 'display:none;');
        }
        $(anchorElement).addClass('plus');
        $(anchorElement).removeClass('minus');
    }

    /**
     * Detects and updates the state of the collapse/expand button
     */
    const changeButtonState = function () {
        if ($("#module-content h2.minus").length <= $("#module-content h2.plus").length) {
            $('#btn_toggle').text(expandText);
            $("#btn_toggle").addClass('plus');
            $("#btn_toggle").removeClass('minus');
        } else {
            $('#btn_toggle').text(collapseText);
            $("#btn_toggle").addClass('minus');
            $("#btn_toggle").removeClass('plus');
        }
    }
    /* Expands section on page load based on the hash. Expands section when the leftnav item is clicked */
    let expandSectionBasedOnHash = function (itemName) {
        let anchorElement = $('div[name="' + itemName + '"]').next(); //anchor element is always the next of div (eg. h2 or h3)
        if ($(anchorElement).hasClass('hol-ToggleRegions')) //if the next element is the collpase/expand button
            anchorElement = $(anchorElement).next();
        try {
            if (anchorElement[0].tagName !== 'H2') {
                anchorElement = $(anchorElement).siblings('h2');
            }

            if ($(anchorElement).hasClass('minus') || $(anchorElement).hasClass('plus'))
                expandSection(anchorElement, "fade");
            $(anchorElement)[0].scrollIntoView();
            window.scrollTo(0, window.scrollY - $('.hol-Header').height());
            changeButtonState();
        } catch (e) { console.debug('Section expand error:', e); }
    }

    // this function higlights the text when the copy button is clicked
    // let selectElement = function(elements) {
    //     let sel, range, el = elements;
    //     if (window.getSelection && document.createRange) { //Browser compatibility
    //         sel = window.getSelection();
    //         window.setTimeout(function(){
    //             range = document.createRange(); //range object
    //             range.selectNodeContents(el); //sets Range
    //             sel.removeAllRanges(); //remove all ranges from selection
    //             sel.addRange(range); //add Range to a Selection.
    //         }, 1);

    //         window.setTimeout(function() {
    //             sel.removeAllRanges();
    //         }, 4000);
    //     }
    // }

    /**
     * Highlights code elements when the copy button is clicked
     * @param {jQuery} elements - The elements to highlight
     */
    const selectElement = function (elements) {
        $(elements).addClass('code-highlight');

        window.setTimeout(function () {
            $(elements).removeClass('code-highlight');
        }, 2000);
    }

    /**
     * Copies text to clipboard using modern Clipboard API with fallback
     * @param {string} text - The text to copy to clipboard
     * @param {jQuery} buttonElement - The button element for animation feedback
     * @private
     */
    const copyToClipboard = function (text, buttonElement) {
        const animateSuccess = () => {
            $(buttonElement).parent().animate({
                opacity: 0.2
            }).animate({
                opacity: 1
            });
        };

        // Modern Clipboard API (preferred)
        if (navigator.clipboard && navigator.clipboard.writeText) {
            navigator.clipboard.writeText(text)
                .then(animateSuccess)
                .catch((err) => {
                    console.debug('Clipboard API failed, using fallback:', err);
                    // Fallback to execCommand for older browsers
                    fallbackCopyToClipboard(text, buttonElement, animateSuccess);
                });
        } else {
            // Fallback for browsers without Clipboard API
            fallbackCopyToClipboard(text, buttonElement, animateSuccess);
        }
    };

    /**
     * Fallback clipboard copy using deprecated execCommand (for older browsers)
     * @param {string} text - The text to copy
     * @param {jQuery} buttonElement - The button element
     * @param {Function} onSuccess - Callback on successful copy
     * @private
     */
    const fallbackCopyToClipboard = function (text, buttonElement, onSuccess) {
        const dummy = $('<textarea>').val(text).appendTo(buttonElement).select();
        document.execCommand('copy');
        $(dummy).remove();
        onSuccess();
    };

    /**
     * Adds code copy functionality in codeblocks
     * The code that needs to be copied must be wrapped in <copy></copy> tags
     * @param {HTMLElement} articleElement - The article element containing code blocks
     * @returns {HTMLElement} The modified article element
     */
    const allowCodeCopy = function (articleElement) {
        $(articleElement).find('pre code').each(function () {
            if ($(this).text().indexOf('<copy>') >= 0) {
                const code = $(document.createElement('code')).html($(this).text());
                $(this).html($(code).html());
            }

            if ($(this).has('copy').length >= 1) {
                $(this).find('copy').contents().unwrap().wrap('<span class="copy-code">');
                $(this).before('<button class="copy-button" title="Copy text to clipboard">' + copyButtonText + '</button>');
            }
        });

        $(articleElement).find('.copy-button').click(function () {
            selectElement($(this).next().find('.copy-code'));

            const codeElement = $(this).next();
            const preElement = $(this).parent();  // The <pre> element has the language class
            // Check if code block is SQL (supports sql, plsql, and language-* variants)
            const isSql = preElement.hasClass('sql') ||
                          preElement.hasClass('language-sql') ||
                          preElement.hasClass('plsql') ||
                          preElement.hasClass('language-plsql');

            let copyText = codeElement.find('.copy-code').map(function () {
                return $(this).text().trim();
            }).get().join('\n');

            // Add trailing newline only for SQL code blocks so last statement executes when pasted
            if (isSql) {
                copyText += '\n';
            }

            copyToClipboard(copyText, this);
        });

        return articleElement;
    }

    /* adds iframe to YouTube videos so that it renders in the same page.
    The MD code should be in the format [](youtube:<enter_video_id>) for it to render as iframe. */
    let renderYouTubeVideos = function (articleElement) {
        $(articleElement).find('a[href^="youtube:"]').each(function () {
            $(this).after('<div class="video-container' + '-' + $(this).attr("href").split(":")[2] + '"><iframe title="video iframe" src="https://www.youtube.com/embed/' + $(this).attr('href').split(":")[1] + '" frameborder="0" allowfullscreen></div>');
            $(this).remove();
        });
        return articleElement;
    }

    /* adds iframe to Oracle Video Hub videos so that it renders in the same page.
    The MD code should be in the format [](videohub:<enter_video_id>) for it to render as iframe. */
    let renderVideoHubVideos = function (articleElement) {
        $(articleElement).find('a[href^="videohub:"]').each(function () {
            $(this).after('<div class="video-container' + '-' + $(this).attr("href").split(":")[2] + '"><iframe id="kaltura_player" title="video iframe" src="https://cdnapisec.kaltura.com/p/2171811/sp/217181100/embedIframeJs/uiconf_id/35965902/partner_id/2171811?iframeembed=true&playerId=kaltura_player&entry_id=' + $(this).attr('href').split(":")[1] + '&flashvars[streamerType]=auto" frameborder="0" allowfullscreen></div>');
            $(this).remove();
        });
        return articleElement;
    }

    /* adds HTML5 video element for direct video file URLs.
    The MD code should be in the format [](video:<enter_video_url>) or [](video:<enter_video_url>:size) for it to render as video.
    Supported sizes: small, medium, large (default: small)
    Supported formats: mp4, webm, ogg/ogv */
    let renderDirectVideos = function (articleElement) {
        $(articleElement).find('a[href^="video:"]').each(function () {
            let href = $(this).attr('href');
            // Remove the 'video:' prefix
            let videoPath = href.substring(6);
            let size = 'small'; // default size

            // Check if size is specified at the end (e.g., :small, :medium, :large)
            let sizeMatch = videoPath.match(/:(small|medium|large)$/);
            if (sizeMatch) {
                size = sizeMatch[1];
                videoPath = videoPath.replace(/:(small|medium|large)$/, '');
            }

            // Determine video type from extension
            let videoType = 'video/mp4'; // default
            if (videoPath.endsWith('.webm')) {
                videoType = 'video/webm';
            } else if (videoPath.endsWith('.ogg') || videoPath.endsWith('.ogv')) {
                videoType = 'video/ogg';
            }

            $(this).after('<div class="video-container-' + size + '"><video controls preload="metadata" title="video"><source src="' + videoPath + '" type="' + videoType + '">Your browser does not support the video tag.</video></div>');
            $(this).remove();
        });
        return articleElement;
    }

    /* remove all content that is not of type specified in the manifest file. Then remove all if tags.*/
    let singlesource = function (markdownContent, type) {
        let ifTagRegExp = new RegExp(/<\s*if type="([^>]*)">([\s\S|\n]*?)<\/\s*if>/gm);
        let contentToReplace = []; // content that needs to be replaced

        if (getParam("type") !== false) {
            type = getParam("type");
        } else if ($.type(type) == 'object') {
            type = Object.keys(type)[0];
        }

        if ($.type(type) !== 'array')
            type = Array(type);

        let matches;
        do {
            matches = ifTagRegExp.exec(markdownContent);
            if (matches === null) {
                $(contentToReplace).each(function (index, value) {
                    markdownContent = markdownContent.replace(value.replace, value.with);
                });
                return markdownContent;
            }
            // convert if type to array
            let all_types = matches[1].split(' '),
                matchFound = false;

            for (let i = 0; i < all_types.length && !matchFound; i++) {
                if ($.inArray(all_types[i], type) >= 0) { // check if type specified matches content
                    matchFound = true;
                }
            }

            // replace with blank if type doesn't match
            // replace with text without if tag (if any if type matches)
            (!matchFound) ?
                contentToReplace.push({ "replace": matches[0], "with": '' }) :
                contentToReplace.push({ "replace": matches[0], "with": matches[2] });

        } while (matches);
    }
    /* converts < > symbols inside the copy tag to &lt; and &gt; */
    let convertBracketInsideCopyCode = function (markdownContent) {
        let copyRegExp = new RegExp(/<copy>([\s\S|\n]*?)<\/copy>/gm);

        markdownContent = markdownContent.replace(copyRegExp, function (code) {
            code = code.replace('<copy>', '');
            code = code.replace('</copy>', '');
            code = code.replace(/</g, '&lt;');
            code = code.replace(/>/g, '&gt;');
            return '<copy>' + code.trim() + '</copy>';
        });

        return markdownContent;
    }
    // Defines the FreeSQL Buttons for Sprints
    let convertFreeSQLButtonTags = function (markdownContent) {
        let sqlCode = "";
        let link = "";

        // If the markdown includes a FreeSQL button...
        if (markdownContent.includes('<freesql-button')) {
            console.log('<freesql-button> tag detected. Now replacing it with the real button.');
            
            // and the author is using a tutorial...
            if (markdownContent.includes('<freesql-button src=')) {
                console.log("<freesql-button> tag includes a source. Using the provided url as the button's link.");
                
                // extract the tutorial link
                markdownContent = markdownContent.replace(new RegExp(/<freesql-button src="([\s\S|\n]*?)">/gm), function (code) {
                    link = code;
                    link = link.replace('<freesql-button src="',"");
                    link = link.replace('">',"");
                    return code;});
                console.log("Tutorial Link: " + link);

            // and the author is using a worksheet...
            } else if (markdownContent.includes('<freesql-button>')) {
                console.log("<freesql-button> tag does not include a source. Building a FreeSQL worksheet link.");
                let worksheetRegExp = new RegExp(/<freesql>([\s\S|\n]*?)<\/freesql>/gm); // Finds all content between the freesql tag. 
    
                // find all code wrapped in <freesql>, concatenate it and...
                markdownContent = markdownContent.replace(worksheetRegExp, function (code){
                    code = code.replace('<freesql>', '');
                    code = code.replace('</freesql>', '');
                    sqlCode += code;
                    return code;
                });

                // create the worksheet's link using the encoded SQL.
                link = 'https://freesql.com/next/worksheet?code=' + encodeURIComponent(sqlCode);
                console.log('Worksheet Link: ' + link);
            } else {console.log('FreeSQL button is not properly formatted.')};
        

            // Replace <freesql-button> with the actual button.
            markdownContent = markdownContent.replace(new RegExp(/<freesql-button([\s\S|\n]*?)>/gm), function (code) {
                code = code.replace(code, '<a href="' + link + 
                    '" target = "_blank"> <button class="freesql-button">Try It Now w/ FreeSQL</button></br></a>');
                console.log("The Free SQL button is now added.")
                return code;
            });
        } else {console.log('No <freesql-button> tag detected');}
        
        return markdownContent; 
    }

    /* injects tracking code into links specified in the utmParams variable */
    let injectUtmParams = function (articleElement) {
        let currentUrl = window.location.href;
        $(utmParams).each(function (index, item) {
            let inParamValue = getParam(item.inParam);
            if (inParamValue) {
                $(articleElement).find('a[href*="' + item.url + '"]').each(function () {
                    let targetUrl = $(this).attr('href');
                    $(this).attr('href', unescape(setParam(targetUrl, item.outParam, inParamValue)));
                });
            }
        });

        /* hack for manual links like this ?lab=xx. Should be removed later. */
        $(utmParams).each(function (index, item) {
            let inParamValue = getParam(item.inParam);
            if (inParamValue) {
                $(articleElement).find('a[href*="?' + queryParam + '="]').each(function () {
                    let targetUrl = $(this).attr('href') + '&' + item.inParam + '=' + inParamValue;
                    $(this).attr('href', unescape(targetUrl));
                });
            }
        });
        /* remove till here */
        return articleElement;
    }

    /*
     * ============================================
     * SECTION 8: UTILITIES
     * ============================================
     */

    /**
     * Sets a query parameter value in a URL
     * @param {string} url - The URL to modify
     * @param {string} paramName - The parameter name
     * @param {string} paramValue - The parameter value
     * @returns {string} The modified URL
     */
    const setParam = function (url, paramName, paramValue) {
        let onlyUrl = (url.split('?')[0]).split('#')[0];
        let params = url.replace(onlyUrl, '').split('#')[0];
        let hashAnchors = url.replace(onlyUrl + params, '');
        hashAnchors = "";

        let existingParamValue = getParam(paramName);
        if (existingParamValue) {
            return onlyUrl + params.replace(paramName + '=' + existingParamValue, paramName + '=' + paramValue) + hashAnchors;
        } else {
            if (params.length === 0 || params.length === 1) {
                return onlyUrl + '?' + paramName + '=' + paramValue + hashAnchors;
            }
            return onlyUrl + params + '&' + paramName + '=' + paramValue + hashAnchors;
        }
    }
    /**
     * Gets a query parameter value from the current URL
     * @param {string} paramName - The parameter name to retrieve
     * @returns {string|boolean} The parameter value or false if not found
     */
    const getParam = function (paramName) {
        const params = window.location.search.substring(1).split('&');
        for (let i = 0; i < params.length; i++) {
            if (params[i].split('=')[0] == paramName) {
                // Fix for LLAPEX-595 to remove characters only before the first '='
                return params[i].split(/=(.*)/s)[1];
            }
        }
        return false;
    }

    /**
     * Creates a short name from a title for URL-friendly identifiers
     * @param {string} title - The title to convert
     * @returns {string} The short name
     */
    const createShortNameFromTitle = function (title) {
        if (!title) {
            console.log("The title in the manifest file cannot be blank!");
            return "ErrorTitle";
        }
        const removeFromTitle = ["-a-", "-in-", "-of-", "-the-", "-to-", "-an-", "-is-", "-your-", "-you-", "-and-", "-from-", "-with-"];
        const folderNameRestriction = ["<", ">", ":", "\"", "/", "\\\\", "|", "\\?", "\\*", "&", "\\.", ","];
        let shortname = title.toLowerCase().replace(/ /g, '-').trim().substr(0, 50);
        $.each(folderNameRestriction, function (i, value) {
            shortname = shortname.replace(new RegExp(value, 'g'), '');
        });
        $.each(removeFromTitle, function (i, value) {
            shortname = shortname.replace(new RegExp(value, 'g'), '-');
        });
        if (shortname.length > 40) {
            shortname = shortname.substr(0, shortname.lastIndexOf('-'));
        }
        return shortname;
    }


    let updateOpenCloseButtonText = function (articleElement, manifestFileContent) {
        let task_type = selectTutorial(manifestFileContent).task_type || manifestFileContent.task_type;
        if (task_type) {
            const default_task_type = "Tasks";
            task_type = task_type.trim();
            collapseText = collapseText.replace(default_task_type, task_type);
            expandText = expandText.replace(default_task_type, task_type);
        }
        return articleElement;
    }

    let showRightAndLeftArrow = function (articleElement, manifestFileContent) {
        let next_page = selectTutorial(manifestFileContent, extendedNav['#next']);
        let prev_page = selectTutorial(manifestFileContent, extendedNav['#prev']);


        if (next_page !== undefined) {
            $('.hol-Footer-rightLink').removeClass('hide').addClass('show').attr({ 'href': unescape(setParam(window.location.href, queryParam, getMDFileName(next_page.filename))), 'title': 'Next' }).text('Next');
        }
        if (prev_page !== undefined) {
            $('.hol-Footer-leftLink').removeClass('hide').addClass('show').attr({ 'href': unescape(setParam(window.location.href, queryParam, getMDFileName(prev_page.filename))), 'title': 'Previous' }).text('Previous');
        }
        return articleElement;
    }

    let setH2Name = function (articleElement) {

        $(articleElement).find('h2').each(function () {
            $(this).before($(document.createElement('div')).attr({
                'name': alphaNumOnly($(this).text()),
                'data-unique': alphaNumOnly($(this).text())
            }));
        });
        return articleElement;
    }

    /**
     * Returns only alphanumeric characters from text
     * @param {string} text - The input text
     * @returns {string} Text with only alphanumeric characters
     */
    const alphaNumOnly = function (text) { return text.replace(/[^[A-Za-z0-9:?\(\)]+?/g, ''); }

    /*
     * ============================================
     * SECTION 7: QA VALIDATION
     * ============================================
     */

    /**
     * Performs QA validation on the article content
     * @param {HTMLElement} articleElement - The article element to validate
     * @param {string} markdownContent - The raw markdown content
     * @param {Object} manifestFileContent - The manifest file content
     * @returns {jQuery} The article element with QA report prepended
     */
    const performQA = function (articleElement, markdownContent, manifestFileContent) {
        let error_div = $(document.createElement('div')).attr('id', 'qa-report').html("<div id='qa-reportheader'></div><div id='qa-reportbody'><ol></ol></div>");
        const more_info = "Please see <a href='https://oracle-livelabs.github.io/common/sample-livelabs-templates/create-labs/labs/workshops/livelabs/?lab=4-labs-markdown-develop-content' target='_blank'>using the LiveLabs template</a> for more information.";

        let urlExists = function (url, callback) {
            $.ajax({
                type: 'HEAD',
                url: url,
                success: function () {
                    callback(true);
                },
                error: function () {
                    callback(false);
                }
            });
        }

        let add_issue = function (error_msg, error_type = "", follow_id = false) {
            if (follow_id) {
                $(error_div).find('ol').append("<li class=" + error_type + ">" + error_msg + " <small onclick=\"window.scrollTo({top:$('." + follow_id + "').offset().top - ($('header').outerHeight() + 10), behavior: 'smooth'});\">(show)</small></li>");
            } else {
                $(error_div).find('ol').append("<li class=" + error_type + ">" + error_msg + "</li>");
            }

        }

        let checkH1 = function (article) {
            if ($(article).find('h1').length !== 1) {
                add_issue("Only a single title is allowed, please edit your Markdown file and remove or recast other content tagged with a single #.", "major-error");
                $(article).find('h1').addClass('error');
            }
        }

        let checkForGerundInTitle = function (manifest) {
            // removed in 26.2
            return;
            if (manifest.workshoptitle.indexOf("ing ") !== -1) {
                //updated to specifiy what Imperative means
                add_issue("Your workshop title uses a gerund. Consider using an imperative verb workshop title, for example, 'Start' instead of 'Starting'.", "major-error")
                // add_issue("Please use an imperative workshop title instead of a gerund,(e.g 'Start' not 'Starting').", "major-error")
            }
        }

        let checkForGerundInLabTitle = function (manifest) {
            // removed in 26.2
            return;
            var i = 0;
            while (i < manifest.tutorials.length) {
                if (manifest.tutorials[i].title.indexOf("ing ") !== -1) {
                    //specifies where imperative issue location(s) within the Lab
                    add_issue("Your lab: '" + manifest.tutorials[i].title + "', uses a gerund. Consider using an imperative verb lab title instead of a gerund, for example, 'Start' instead of 'Starting'.", "major-error")
                }
                i++;
            }
        }


        let checkForHtmlTags = function (markdown) {
            let count = (markdown.match(new RegExp("<a href=", "g")) || []).length;
            if (count == 1)
                add_issue("There is " + count + " occurrence of HTML (for example: &lt;a href=...&gt;) in your Markdown. Please do not embed HTML in Markdown.");
            else if (count > 1)
                add_issue("There are " + count + " occurrences of HTML (for example: &lt;a href=...&gt;) in your Markdown. Please do not embed HTML in Markdown.");
        }

        let checkSecondH2Tag = function (article) {
            if ($(article).find('h2:eq(1)').text().substr(0, 4).indexOf("Task") !== 0) {
                $(article).find('h2:eq(1)').addClass(getFollowId());
                add_issue("The second H2 tag (##) of your Markdown file should be labeled with \"Task\".", "", getFollowId());
            }
        }

        let checkImages = function (article) {
            $(article).find('img').each(function () {
                // skip the modalImg img frame from QA check
                if ($(this).attr("id") === "modalImg") {
                    return;
                }
                try {
                    // if ($(this).attr('src').split('/')[$(this).attr('src').split('/').length - 2].indexOf("images") !== 0) {
                    if ($(this).attr('src').indexOf("/images/") <= 0) {
                        add_issue("Your images must be in an <strong>images</strong> folder. Please rename the folder and update your Markdown.");
                        return false; // to break the each loop
                    }
                } catch (e) {
                    add_issue("Your images must be in an <strong>images</strong> folder. Please rename the folder and update your Markdown.");
                    return false;
                };
            });
        }

        let checkImagesAltText = function (article) {
            $(article).find('img').each(function () {
                // if ($(this).attr("alt").length <1 || (!$(this).attr("alt")) || $(this).attr("alt") == '' || $(this).attr("alt") == undefined || $(this).attr("alt") == 0) {
                try {
                    if ($(this).attr('alt').length < 1 || (!$(this).attr("alt")) || $(this).attr("alt") == '' || $(this).attr("alt") == undefined || $(this).attr("alt") == 0) {
                        add_issue("Please make sure that all images contain alternate text.");
                        return false;
                    }

                } catch (e) {
                    return false;
                };
            })
        }


        let checkCodeBlockFormat = function (markdown) {
            let count = (markdown.match(/\````/g) || []).length;
            if (count == 1) {
                add_issue("Your Markdown file has " + count + " codeblock with 4 (````). This should be changed to 3 (```). Please review your Markdown and make the necessary changes.")
            } else if (count > 1) {
                add_issue("Your Markdown file has " + count + " codeblocks with 4 (````). This should be changed to 3 (```). Please review your Markdown and make the necessary changes.")
            }
        }

        let updateCount = function (article) {
            $(error_div).find('#qa-reportheader').html('Total Issues: ' + $(error_div).find('li').length);
            if (!$(error_div).find('li').length) {
                $(error_div).find('#qa-reportbody').hide();
            } else {
                $(error_div).find('#qa-reportbody').show();
                if ($(error_div).find('#qa-reportbody p').length === 0)
                    $(error_div).find('#qa-reportbody').append('<p>' + more_info + '</p>');
            }
        }

        let checkLinkExists = function (article) {
            $(article).find('a').each(function () {
                let url = $(this).attr('href');
                let url_text = $(this).text();
                urlExists(url, function (exists) {
                    if (!exists) {
                        $('a[href$="' + url + '"]').addClass('error ' + getFollowId());
                        add_issue("This URL may be broken: <a href='" + url + "' target='_blank'>" + url_text + "</a>", "major-error", getFollowId());
                        updateCount(article);
                    }
                });
            });
        }

        let checkImageExists = function (article) {
            $(article).find('img').each(function () {
                // skip the modalImg img frame from QA check
                if ($(this).attr("id") === "modalImg") {
                    return;
                }
                let url = $(this).attr('src');
                let url_text = $(this).attr('src').split('/')[$(this).attr('src').split('/').length - 1];
                urlExists(url, function (exists) {
                    if (!exists) {
                        ;
                        $('img[src$="' + url + '"]').addClass('error ' + getFollowId());
                        add_issue("The link to image <strong>" + url_text + "</strong> is broken.", "major-error", getFollowId())
                        updateCount(article);
                    }
                });
            });
        }

        let checkIfSectionExists = function (article, section_name) {
            if ($(article).find('div[name="' + alphaNumOnly(section_name) + '"]').length === 0)
                add_issue("You are missing <strong>" + section_name + "</strong> section.");
        }

        let checkIndentation = function (article) {
            $(article).find('section:not(:first-of-type)').each(function () {
                let tag_list = [];
                if ($(this).find('h2').text().toUpperCase().trim().indexOf("Task") == 0) {
                    $(this).children().each(function () {
                        tag_list.push($(this).prop('tagName'));
                    });

                    if ($.inArray("UL", tag_list) !== -1 & $.inArray("OL", tag_list) == -1) {
                        add_issue("In section <strong>" + $(this).find('h2').text() + "</strong>, your steps are not numbered. Numbered steps should follow your STEP element.", "minor-error");
                        $(this).find('h2').addClass('format-error');
                    }

                    if ($.inArray("PRE", tag_list) > $.inArray("OL", tag_list)) {
                        $(this).children('pre').addClass('format-error ' + getFollowId());
                        add_issue("Your codeblock is not indented correctly. Add spaces to indent your codeblock. Use one tab stop (4 spaces).", "minor-error", getFollowId());
                    }

                    $(this).find('img').each(function () {
                        if ($(this).parent().parent().prop('tagName').indexOf("LI") == -1 && $(this).parent().parent().prop('tagName').indexOf("OL") == -1 && $(this).parent().parent().prop('tagName').indexOf("UL") == -1) {
                            // $(this).parents('section').children('h2').addClass('format-error');
                            $(this).addClass('format-error ' + getFollowId());
                            add_issue("The image <strong>" + $(this).attr('src').split('/')[$(this).attr('src').split('/').length - 1] + "</strong> is not aligned with your text blocks. Add spaces to indent your image.", "minor-error", getFollowId());
                        }
                    });
                }
            });
        }

        let getFollowId = function () { return 'error_' + $(error_div).find('li').length; }

        checkH1(articleElement);
        checkForGerundInTitle(manifestFileContent);
        checkForGerundInLabTitle(manifestFileContent);
        checkForHtmlTags(markdownContent);
        checkImages(articleElement);
        checkImagesAltText(articleElement);
        checkCodeBlockFormat(markdownContent);
        checkSecondH2Tag(articleElement);
        if (!window.location.href.indexOf("localhost") && window.location.href.indexOf("127.0.0.1")) {
            checkLinkExists(articleElement);
        }
        checkImageExists(articleElement);
        checkIfSectionExists(articleElement, "Acknowledgements");
        // checkIfSectionExists(articleElement, "See an issue?");
        checkIndentation(articleElement);
        updateCount(articleElement);

        return $(articleElement).prepend(error_div);
    }

    // picked up as it is from: https://www.w3schools.com/howto/howto_js_draggable.asp
    function dragElement(elmnt) {
        var pos1 = 0,
            pos2 = 0,
            pos3 = 0,
            pos4 = 0;
        if (document.getElementById(elmnt.id + "header")) {
            // if present, the header is where you move the DIV from:
            document.getElementById(elmnt.id + "header").onmousedown = dragMouseDown;

            $('#qa-reportheader').dblclick(function () { // this line has been added to collapse qa report body
                $('#qa-reportbody').fadeToggle();
            });

        } else {
            // otherwise, move the DIV from anywhere inside the DIV:
            elmnt.onmousedown = dragMouseDown;
        }

        function dragMouseDown(e) {
            e = e || window.event;
            e.preventDefault();
            // get the mouse cursor position at startup:
            pos3 = e.clientX;
            pos4 = e.clientY;
            document.onmouseup = closeDragElement;
            // call a function whenever the cursor moves:
            document.onmousemove = elementDrag;
        }

        function elementDrag(e) {
            e = e || window.event;
            e.preventDefault();
            // calculate the new cursor position:
            pos1 = pos3 - e.clientX;
            pos2 = pos4 - e.clientY;
            pos3 = e.clientX;
            pos4 = e.clientY;
            // set the element's new position:
            elmnt.style.top = (elmnt.offsetTop - pos2) + "px";
            elmnt.style.left = (elmnt.offsetLeft - pos1) + "px";
        }

        function closeDragElement() {
            // stop moving when mouse button is released:
            document.onmouseup = null;
            document.onmousemove = null;
        }
    }

}();

/**
 * Global function to check quiz answers
 * Called by quiz check buttons via onclick
 * @param {string} quizId - The quiz element's data-quiz-id
 * @param {boolean} isMultiple - Whether this is a multiple-answer quiz (checkboxes)
 */
function checkQuizAnswer(quizId, isMultiple) {
    let quiz = document.querySelector('[data-quiz-id="' + quizId + '"]');
    if (!quiz) return;

    let options = quiz.querySelectorAll('.ll-quiz-option');
    let resultDiv = quiz.querySelector('.ll-quiz-result');
    let explanationDiv = quiz.querySelector('.ll-quiz-explanation');
    let checkBtn = quiz.querySelector('.ll-quiz-check');
    let retryBtn = quiz.querySelector('.ll-quiz-retry');
    let allCorrect = true;
    let anySelected = false;
    let isScored = quiz.getAttribute('data-scored') === 'true';
    let wasAnswered = quiz.getAttribute('data-answered') === 'true';
    let wasCorrect = quiz.getAttribute('data-correct') === 'true';

    options.forEach(function (option) {
        let input = option.querySelector('input');
        let feedback = option.querySelector('.ll-quiz-feedback');
        let isCorrect = option.getAttribute('data-correct') === 'true';
        let isSelected = input.checked;

        if (isSelected) anySelected = true;

        // Reset previous state
        option.classList.remove('correct', 'incorrect', 'missed');
        feedback.textContent = '';

        if (isSelected && isCorrect) {
            option.classList.add('correct');
            feedback.textContent = '✓';
        } else if (isSelected && !isCorrect) {
            option.classList.add('incorrect');
            feedback.textContent = '✗';
            allCorrect = false;
        } else if (!isSelected && isCorrect) {
            option.classList.add('missed');
            allCorrect = false;
        }

        // Disable input after checking
        input.disabled = true;
    });

    if (!anySelected) {
        resultDiv.textContent = 'Please select an answer.';
        resultDiv.className = 'll-quiz-result warning';
        // Re-enable inputs
        options.forEach(function (option) {
            option.querySelector('input').disabled = false;
        });
        return;
    }

    // Show result
    if (allCorrect) {
        resultDiv.textContent = 'Correct!';
        resultDiv.className = 'll-quiz-result success';
    } else {
        resultDiv.textContent = 'Not quite. The correct answer' + (isMultiple ? 's are' : ' is') + ' highlighted.';
        resultDiv.className = 'll-quiz-result error';
    }

    // Show explanation if present
    if (explanationDiv) {
        explanationDiv.style.display = 'block';
    }

    // Hide check button, show retry button
    checkBtn.style.display = 'none';
    if (retryBtn) {
        retryBtn.style.display = 'inline-block';
    }

    // Update quiz state
    quiz.setAttribute('data-answered', 'true');
    quiz.setAttribute('data-correct', allCorrect.toString());

    // Update score tracker if this is a scored quiz
    if (isScored) {
        updateQuizScore(wasAnswered, wasCorrect, allCorrect);
    }
}

/**
 * Reset a quiz to allow retry
 * @param {string} quizId - The quiz element's data-quiz-id
 */
function retryQuiz(quizId) {
    let quiz = document.querySelector('[data-quiz-id="' + quizId + '"]');
    if (!quiz) return;

    let options = quiz.querySelectorAll('.ll-quiz-option');
    let resultDiv = quiz.querySelector('.ll-quiz-result');
    let explanationDiv = quiz.querySelector('.ll-quiz-explanation');
    let checkBtn = quiz.querySelector('.ll-quiz-check');
    let retryBtn = quiz.querySelector('.ll-quiz-retry');
    let isScored = quiz.getAttribute('data-scored') === 'true';
    let wasCorrect = quiz.getAttribute('data-correct') === 'true';

    // Reset all options
    options.forEach(function (option) {
        let input = option.querySelector('input');
        let feedback = option.querySelector('.ll-quiz-feedback');

        option.classList.remove('correct', 'incorrect', 'missed');
        feedback.textContent = '';
        input.checked = false;
        input.disabled = false;
    });

    // Reset result and explanation
    resultDiv.textContent = '';
    resultDiv.className = 'll-quiz-result';
    if (explanationDiv) {
        explanationDiv.style.display = 'none';
    }

    // Show check button, hide retry button
    checkBtn.style.display = 'inline-block';
    if (retryBtn) {
        retryBtn.style.display = 'none';
    }

    // Update quiz state - mark as not answered for retry
    quiz.setAttribute('data-answered', 'false');
    quiz.setAttribute('data-correct', 'false');

    // Update score tracker if this is a scored quiz (remove from answered count)
    if (isScored) {
        updateQuizScore(true, wasCorrect, false, true);
    }
}

/**
 * Update the quiz score tracker and inline score displays
 * @param {boolean} wasAnswered - Whether quiz was previously answered
 * @param {boolean} wasCorrect - Whether quiz was previously correct
 * @param {boolean} isCorrect - Whether quiz is now correct
 * @param {boolean} isRetry - Whether this is a retry (removing answer)
 */
function updateQuizScore(wasAnswered, wasCorrect, isCorrect, isRetry) {
    let tracker = document.getElementById('ll-quiz-score-tracker');
    if (!tracker) return;

    let total = parseInt(tracker.getAttribute('data-total'), 10);
    let correct = parseInt(tracker.getAttribute('data-correct'), 10);
    let answered = parseInt(tracker.getAttribute('data-answered'), 10);

    if (isRetry) {
        // Removing an answer (retry)
        answered--;
        if (wasCorrect) correct--;
    } else if (wasAnswered) {
        // Updating an existing answer
        if (wasCorrect && !isCorrect) correct--;
        else if (!wasCorrect && isCorrect) correct++;
    } else {
        // New answer
        answered++;
        if (isCorrect) correct++;
    }

    tracker.setAttribute('data-correct', correct);
    tracker.setAttribute('data-answered', answered);

    // Calculate percentage
    let percentage = answered > 0 ? Math.round((correct / total) * 100) : 0;

    // Update all inline score displays next to "Scored Quiz" labels
    let scoreDisplays = document.querySelectorAll('.ll-quiz-score-display');
    let scoreText = '';

    if (answered < total) {
        scoreText = correct + '/' + total + ' correct (' + percentage + '%) - ' + (total - answered) + ' remaining';
    } else {
        scoreText = correct + '/' + total + ' correct (' + percentage + '%)';
    }

    scoreDisplays.forEach(function (display) {
        display.textContent = scoreText;

        // Update styling based on current performance
        display.classList.remove('passing', 'failing');
        if (answered === total) {
            let config = document.getElementById('ll-quiz-config');
            let passingScore = config ? parseInt(config.getAttribute('data-passing'), 10) : 80;
            if (percentage >= passingScore) {
                display.classList.add('passing');
            } else {
                display.classList.add('failing');
            }
        }
    });

    // Handle badge container when all answered
    let badgeContainer = tracker.querySelector('.ll-quiz-badge-container');

    if (answered >= total) {
        let config = document.getElementById('ll-quiz-config');
        let passingScore = config ? parseInt(config.getAttribute('data-passing'), 10) : 80;
        let badgePath = config ? config.getAttribute('data-badge') : null;

        if (percentage >= passingScore && badgePath) {
            // Get the base path from an existing image in the article, or construct from URL
            let fullBadgePath = badgePath;
            if (!badgePath.startsWith('http') && !badgePath.startsWith('/')) {
                // Relative path - need to prepend base path
                let existingImg = document.querySelector('#module-content img');
                if (existingImg && existingImg.src) {
                    // Extract base path from existing image src
                    let imgSrc = existingImg.src;
                    let basePath = imgSrc.substring(0, imgSrc.lastIndexOf('/') + 1);
                    // Remove 'images/' from base path if badge path starts with 'images/'
                    if (badgePath.startsWith('images/') && basePath.endsWith('images/')) {
                        basePath = basePath.slice(0, -7); // remove trailing 'images/'
                    }
                    fullBadgePath = basePath + badgePath;
                } else {
                    // Fallback: try to construct path from current lab URL
                    // Look for lab path in selected nav item or URL hash
                    let selectedNav = document.querySelector('.selected a');
                    if (selectedNav && selectedNav.href) {
                        let labPath = selectedNav.href;
                        // Extract directory from lab path
                        let baseDir = labPath.substring(0, labPath.lastIndexOf('/') + 1);
                        fullBadgePath = baseDir + badgePath;
                    }
                }
            }
            badgeContainer.innerHTML = '<div class="ll-quiz-badge-message">Congratulations! You passed with ' + percentage + '%!</div>' +
                '<div class="ll-quiz-badge-content">' +
                '<img src="' + fullBadgePath + '" alt="Achievement Badge" class="ll-quiz-badge-preview">' +
                '<a href="' + fullBadgePath + '" download class="ll-quiz-badge-download">Download Your Badge</a>' +
                '</div>' +
                '<p class="ll-quiz-badge-disclaimer">Disclaimer: This badge is not an official Oracle Certification. We do not track or store any user data.</p>';
            badgeContainer.style.display = 'block';
            // Move badge container to appear right after the last scored quiz
            let scoredQuizzes = document.querySelectorAll('.ll-quiz-scored');
            if (scoredQuizzes.length > 0) {
                let lastScoredQuiz = scoredQuizzes[scoredQuizzes.length - 1];
                lastScoredQuiz.parentNode.insertBefore(badgeContainer, lastScoredQuiz.nextSibling);
            }
            // Scroll badge into view with smooth animation
            setTimeout(function() {
                badgeContainer.scrollIntoView({ behavior: 'smooth', block: 'center' });
            }, 300);
        } else if (percentage < passingScore) {
            badgeContainer.innerHTML = '<div class="ll-quiz-badge-message ll-quiz-not-passed">Score: ' + percentage + '%. You need ' + passingScore + '% to pass. Click "Try Again" on any quiz to retry.</div>';
            badgeContainer.style.display = 'block';
            // Move badge container to appear right after the last scored quiz
            let scoredQuizzes = document.querySelectorAll('.ll-quiz-scored');
            if (scoredQuizzes.length > 0) {
                let lastScoredQuiz = scoredQuizzes[scoredQuizzes.length - 1];
                lastScoredQuiz.parentNode.insertBefore(badgeContainer, lastScoredQuiz.nextSibling);
            }
            // Scroll into view so user sees they didn't pass
            setTimeout(function() {
                badgeContainer.scrollIntoView({ behavior: 'smooth', block: 'center' });
            }, 300);
        } else {
            badgeContainer.style.display = 'none';
        }
    } else {
        badgeContainer.style.display = 'none';
    }
}

let download = function () {

    //enables download of files
    let download_file = function (filename, text) {
        let pom = document.createElement('a');
        pom.setAttribute('href', 'data:html/plain;charset=utf-8,' + encodeURIComponent(text));
        pom.setAttribute('download', filename);
        if (document.createEvent) {
            let event = document.createEvent('MouseEvents');
            event.initEvent('click', true, true);
            pom.dispatchEvent(event);
        } else {
            pom.click();
        }
    }

    $.when($('img').each(function () {
        $(this).css('max-width', '75%');
        if ($(this).attr('src').indexOf('http') == -1)
            $(this).attr('src', location.protocol + '//' + location.host + location.pathname + $(this).attr('src'));
    }),
        $('pre button').remove(),
        $('pre').attr('style', 'white-space: pre-wrap; white-space: -moz-pre-wrap; white-space: -pre-wrap; white-space: -o-pre-wrap; word-wrap: break-word; max-width: 80%;'),
        $("#module-content h2:not(:eq(0))").nextAll().show('fast'),
        $('h2').removeClass('plus minus'),
        $('#btn_toggle').remove()).done(function () {
            download_file($('.selected span').text().replace(/[^[A-Za-z0-9:?]+?/g, '') + '.html', '<html><head><link rel="stylesheet" href="https://oracle-livelabs.github.io/common/redwood-hol/img/favicon.ico" /></head><body style="padding-top: 0px;">' + $('#contentBox')[0].outerHTML + '</body></html>');
        });
}

/*!
######################################################
# ORA_APEX.JS
######################################################
*/
if (location.hostname.includes("livelabs.oracle.com")) {
    var script = document.createElement("script");
    script.type = "text/javascript";
    script.src = "https://www.oracle.com/us/assets/metrics/ora_apex.js";
    document.head.appendChild(script); 
  }
  
