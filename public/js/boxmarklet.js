(function(){
  var v = "1.3.2";
  if (window.jQuery === undefined || window.jQuery.fn.jquery < v) {
    var done = false;
    var script = document.createElement("script");
    script.src = "https://ajax.googleapis.com/ajax/libs/jquery/" + v + "/jquery.min.js";
    script.onload = script.onreadystatechange = function(){
      if (!done && (!this.readyState || this.readyState == "loaded" || this.readyState == "complete")) {
        done = true;
        initBoxmarklet();
      }
    };
    document.getElementsByTagName("head")[0].appendChild(script);
  } else {
    initBoxmarklet();
  }

  function initBoxmarklet() {
    (window.boxmarklet = function() {
      
      var thePanelLocation, panelCss;
      var APP_URL = 'https://boxmarklet.herokuapp.com/', //Edit this to your own URL
      documentLocation = document.location,
      thePanelLocation = APP_URL + 'css/boxmarklet.css' //'?r=' + Math.random()*99999999;

      // Load Stylesheets for the bookmarklet
      function loadStyles() {
        if ($('#boxmarklet-stylesheet').length > 0) {
          return $('#boxmarklet-stylesheet')
        }
        panelCss = document.createElement("link");
        panelCss.setAttribute("href", thePanelLocation);
        panelCss.setAttribute("rel", "stylesheet");
        panelCss.setAttribute('id', "boxmarklet-stylesheet")
        panelCss.setAttribute("type", "text/css");
        document.getElementsByTagName("head")[0].appendChild(panelCss);
      }
      
      // Create panel and show it
      function showPanel() {
        if ($('#boxmarklet-panel').length > 0) {
          return $('#boxmarklet-panel')
        }
        thePanel = document.createElement("div");
        thePanel.id = "boxmarklet-panel";
        jQuery(thePanel).css('opacity', '0');

        html = '<div class="true clearfix" id="boxmarklet-header">'
        html += '<div class="container clearfix">'
        html +=   '<p><span id="boxmarklet-message"></span><span id="boxmarklet-ellipses"></span></p>'
        html +=  '</div>'
        html += '</div>'

        thePanel.innerHTML = html;
        jQuery("body").prepend(thePanel);

        jQuery("#boxmarklet-panel").animate({
            opacity: 1
        });
      }
      
      // Set message in the panel with optional loading ellipses
      function setPanelStatus(message, loading) {
        showPanel()
        $("#boxmarklet-message").html(message);
        if (loading) {
          var ellipse = $('#boxmarklet-ellipses')[0]
          window.setInterval(function() {
              ellipse.innerHTML = (ellipse.innerHTML.length < 3) ? ellipse.innerHTML + '.': '';
          },
          500); 
        }
      }
      
      // Hide panel, destroy the inserted dom elements from the page
      function destroyPanel() {
        if ($('#boxmarklet-panel').length > 0) {
          $('#boxmarklet-panel').remove();
        }
      }
      
      // Callbacks for jsonp respnose from boxmarklet web service
      callbacks = {
        "save_success": function(args) {
            setPanelStatus(args.message);
            window.setTimeout(function() {
                destroyPanel();
            },
            5000);
        },
        "unauthorized": function(args) {
            var panelMessage = args.message + '<br /><a id="boxmarklet-authorization" href="' + args.auth_url + '">Click here</a>';
            panelMessage += ' to authorize boxmarklet to upload web page PDFs in your account.'
            setPanelStatus(panelMessage);
            $('#boxmarklet-authorization').click(function(e){
              e.preventDefault();
              setPanelStatus('Waiting for authorization to complete', true);
              var w = window,
                u = args.auth_url,
                l = document.location,
                timer, win;
              win = w.open(u, 't', 'toolbar=0,resizable=0,status=1,width=1000,height=470')
              function polling() {
                if (win && win.closed) {
                  clearInterval(timer);
                  destroyPanel();
                  panelMessage = "Awesome! Now click on the bookmarklet above to send web page's PDF to your box account";
                  setPanelStatus(panelMessage, false);
                }
              }
              timer = setInterval(polling,100);
            });
        }
      };
      
      // Init code  
      loadStyles();
      setPanelStatus('Sending PDF version of the page to Box',true);
      var url = APP_URL + 'validate_and_save?url=' + encodeURIComponent(documentLocation) + '&title=' + encodeURIComponent(document.title) + '&jsoncallback=?';

      $.getJSON(url, function(data) {
        console.info(data);
        destroyPanel();
        callbacks[data.status](data)
      });
    })();
  }
})();
