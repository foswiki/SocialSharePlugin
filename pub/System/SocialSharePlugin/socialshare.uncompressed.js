"use strict";
jQuery(function($) {
  $(document).on("click", ".socialShareButton", function() {
    var url = foswiki.getScriptUrl("rest", "RenderPlugin", "template");

    $.ajax({
      url: url, 
      data: {
        "name": "socialshare",
        "expand": "dialog",
        "render": "on",
        "topic": foswiki.getPreference("WEB") + "." + foswiki.getPreference("TOPIC")
      },
      success: function(content) { 
        var $content = $(content);
        $.blockUI({
          message: $content,
          focusInput: false,
          blockMsgClass: "socialShareDialog",
          onBlock: function() {
            $(".blockOverlay").on("click", function() {
              $.unblockUI(); 
              return false;
            });
            $content.find("a").on("click", function() {
              $.unblockUI();
            });
          }
        });
      },
      error: function(xhr) {
        throw("ERROR: can't load dialog xhr=",xhr);
      }
    }); 
  });
});
