$(document).ready(function() {
  $(this).scrollTop(0); // pls keep my aps on the map

  // hover actions for on-map APs
  $(':not(.dragging) .drag_handle').hover(
    function () {
      if (!this.parentNode.parentNode.parentNode.classList.contains('dragging')) {
        if (this.parentNode.parentNode.parentNode.classList.contains('on-map')) {
          // dim the map
          $('#site_map').css({"opacity":"0.5", "transition":"0.5s"});
        }
      }
    }, function () {
      $('#site_map').css("opacity", "1");
    });

  // hover and click actions for navigation (ie. captions)
  $('#buttons img').hover(function () {
    $('#button_info').text($(this).attr('title'));
  }, function () {
    $('#button_info').text(" ");
  });
  $('#edit_toggle').click(function () {
    $('#button_info').text($(this).attr('title'));
  });

  // resize action for keeping APS in their proper place on the map
  window.addEventListener('resize', function () {
    $("#added li").each(function(i) {
      var coords = screenify(
        parseFloat(this.getAttribute('data-propx')), 
        parseFloat(this.getAttribute('data-propy')),
        $('#site_map'));
      this.style.transform = 
      this.style.webkitTransform = 
        'translate(' + coords[0] + 'px, ' + coords[1] + 'px)';
      this.setAttribute('data-x', coords[0]);
      this.setAttribute('data-y', coords[1]);
    });
  });

  // page load setup
  setApProperties();
  setButtonProperties();
  var li = $("#not_added li").get();
  sortList(li);
  $('#menu_wrapper').css("display", "none");

  // form button reset
  $('.disabled_button').each(function () {
    $(this).attr('disabled', 'disabled');
  });

  interact('.draggable')
    .draggable({
      // call this function on every dragmove event
      onmove: dragMoveListener,
      onstart: function (event) {
        event.target.classList.add('dragging');
        $('#right_pane').css('z-index','0');
        $('#site_map').css("opacity", "1");
        if (event.target.parentNode.id == 'added') {
          document.getElementById('added').appendChild(event.target);
        }
      }
      // call onend on every dragend event
    })
    .allowFrom('.drag_handle')
    // .inertia(true)

    .restrict({
      drag: document.getElementById("main_dropzone"),
      endOnly: true,
      elementRect: { top: 0, left: 0, bottom: 1, right: 1 }
    });

  interact('#right_pane')
    .dropzone({
      accept: ".droppable",
      overlap: 0.2,

      ondragenter: function (event) {
        // feedback the possibility of a drop
        document.getElementById('ap_menu').classList.add('right-drop-target');
        event.relatedTarget.classList.remove('on-map');
        event.relatedTarget.classList.add('off-map');
      },

      ondragleave: function (event) {
        // remove the drop feedback style
        document.getElementById('ap_menu').classList.remove('right-drop-target');
        event.relatedTarget.classList.add('on-map');
        event.relatedTarget.classList.remove('off-map');
      },

      ondrop: function (event) {
        // remove AP from the list, add to map
        document.getElementById('ap_menu').classList.remove('right-drop-target');
        $('#right_pane').css('z-index','1');
        event.relatedTarget.classList.remove('dragging');
        event.relatedTarget.classList.remove('on-map-dropped');
        event.relatedTarget.setAttribute('data-x', 0);
        event.relatedTarget.setAttribute('data-y', 0);
        // make database forget about x/y position
        updatePositionData(event.relatedTarget.id, [null, null]);
        document.getElementById("not_added").appendChild(event.relatedTarget);
        // sort the list of APs
        var li = $("#not_added li").get();
        sortList(li);

        $("#not_added li").each(function(i) {
          this.style.transform = "none";
          this.style.webkitTransform = "none";
        });
      },

      ondropdeactivate: function (event) {
        // remove active dropzone feedback
        document.getElementById('ap_menu').classList.remove('right-drop-target');
      }
    })
  
  interact('#site_img')
    .dropzone({
      accept: ".droppable",
      overlap: 1,

      ondrop: function (event) {
        // if the AP pane is closed we don't want to update
        if (document.getElementById('menu_wrapper').style.display != 'none') {
          // otherwise remove AP from list and add to map (if not already on map)
          $('#right_pane').css('z-index','1');
          event.relatedTarget.classList.remove('dragging');
          var dropRect = event.relatedTarget.getBoundingClientRect();
          var x = dropRect.left;
          var y = dropRect.top + window.scrollY;
          event.relatedTarget.style.transform = 
          event.relatedTarget.style.webkitTransform = 
            'translate(' + x + 'px, ' + y + 'px)';
          event.relatedTarget.setAttribute('data-x', x);
          event.relatedTarget.setAttribute('data-y', y);

          if (!event.relatedTarget.classList.contains('on-map-dropped')) {
            event.relatedTarget.classList.add('on-map-dropped');
            document.getElementById("added").appendChild(event.relatedTarget);
          }
          var percent = percentify(x, y, $('#site_map'));
          event.relatedTarget.setAttribute('data-propx', percent[0]);
          event.relatedTarget.setAttribute('data-propy', percent[1]);
          // send new x/y to database
          updatePositionData(event.relatedTarget.id, percent);
        }
      },
    })
});

function dragMoveListener (event) {
  // if the AP pane is closed we don't want to move things
  if (document.getElementById('menu_wrapper').style.display != 'none') {
    var target = event.target,
    // keep the dragged position in the data-x/data-y attributes
    x = (parseInt(target.getAttribute('data-x')) || 0) + event.dx,
    y = (parseInt(target.getAttribute('data-y')) || 0) + event.dy;

    // translate the element
    target.style.webkitTransform =
    target.style.transform =
      'translate(' + x + 'px, ' + y + 'px)';

    // update the position attributes
    target.setAttribute('data-x', x);
    target.setAttribute('data-y', y);
    var percent = percentify(x, y, $('#site_map'));
    target.setAttribute('data-propx', percent[0]);
    target.setAttribute('data-propy', percent[1]);
  } else {
    event.target.classList.remove('dragging');
  }
}

function moveTheThing (thing) {
  // absolute positioning on lists is weird
  var rect = thing.getBoundingClientRect();
  // proportion of window size to actual image size.
  // image hasn't finished loading yet so we have to do special math
  // based on the full dimensions of the image to figure out where
  // to put the APs on the map
  var frac = $(window).height()/$('#site_map').data('dimy');
  var coords = [$(thing).data('propx')*$('#site_map').data('dimx')*frac,
                  $(thing).data('propy')*$(window).height()]
  var x = coords[0] - rect.left;
  var y = coords[1] - rect.top - window.scrollY;
  thing.style.transform = 
  thing.style.webkitTransform = 
    'translate(' + x + 'px, ' + y + 'px)';
  thing.setAttribute('data-x', x);
  thing.setAttribute('data-y', y);
}

function flashMessage (msg) {
  $('#flash').text(msg).css('display', 'initial');
  window.setTimeout(function () {
    $('#flash').css('display', 'none');
  }, 5000);
}

function clearWarnings () {
  $('.warning').css('display','none');
}

function setApProperties () {
  // move icons on map to correct positions and set up for dragging
  // also set on-map class
  $("#added li").each(function(i) {
    moveTheThing(this);
    this.classList.add('on-map');
    this.classList.remove('off-map');
    this.classList.add('on-map-dropped');
  });
  $("#not_added li").each(function(i) {
    this.classList.add('off-map');
    if ($('#site_img').data('img') == "") {
      this.classList.remove('draggable');
    }
  });
}

function setButtonProperties () {
  if ($('#site_text').text() == "") {
    // no site chosen
    $('#edit_site_button').addClass('disabled');
    $('#new_ap_button').addClass('disabled');
    $('#edit_toggle').addClass('disabled');
    $('#upload_button').addClass('disabled');
  }
  if ($('#site_img').data('x') == "") {
    // no image associated with site
    $('#new_ap_button').addClass('disabled');
    $('#edit_toggle').addClass('disabled');
    $('#upload_button').addClass('disabled');
  }
}

function updatePositionData (id, proportions) {
  // proportions come from percentify unless they're null
  $.ajax({
    type: 'POST',
    url: '/move',
    data: $.param({coords: {id: id, x_pos: proportions[0], y_pos: proportions[1]}})
  })
}

function sortList (li) {
  li.sort(function(a,b) {
    a = $('strong', a).text();
    b = $('strong', b).text();

    return (a < b) ? -1 : ((a > b) ? 1 : 0);
  });
  $('#not_added').append(li);
}

function screenify (wp, hp, element) {
  // turns percentages into window pixels. pass numbers between 0-1, and
  // an element (jquery object) to compare to with data-dimx and data-dimy
  return [$(element).width()*wp, $(element).height()*hp];
}

function percentify (w, h, element) {
  // turns window pixels into percentages. returns numbers between 0-1
  // element is a jquery object
  if (w === null && h === null) {
    return [null, null];
  }
  return [w/$(element).width(), h/$(element).height()];
}

function showView (view) {
  // disables the buttons on the right pane and the menu, then makes view (jQuery) visible
  $('#buttons').addClass('disabled');
  $('#wrapper').css('display','none');
  $('#button_info').css('display','none');
  view.css('display','initial');
}

function hideView (view) {
  // hides view (jQuery), then re-enables menu and buttons
  view.css('display','none');
  $('#button_info').css('display','');
  $('#wrapper').css('display','initial');
  $('#buttons').removeClass('disabled');
}

function resetPos () {
  // put all APs for this site back into the list
  $('#added li').each(function () {
    $(this).removeClass('on-map-dropped');
    $(this).data('x', 0);
    $(this).data('y', 0);
    updatePositionData(this.id, [null, null]);
    $('#not_added')[0].appendChild(this);
    var li = $("#not_added li").get();
    sortList(li);
  });

  $("#not_added li").each(function(i) {
    this.style.transform = "none";
    this.style.webkitTransform = "none";
  });
  location.reload();
}

function toggle () {
  // open and close the AP menu
  info = document.getElementById('info_pane');
  menu = document.getElementById('menu_wrapper');
  if (menu.style.display == 'none') {
    menu.style.display = 'initial';
    info.style.display = 'none';
    $('#edit_toggle')
      .attr('src', '/images/nav/edit_close.png')
      .attr('title', 'Close AP Menu');

  } else {
    menu.style.display = 'none';
    info.style.display = '';
    $('#edit_toggle')
      .attr('src', '/images/nav/edit_open.png')
      .attr('title', 'Open AP Menu');
  }
}

function showInfo (dict) {
  // shows info for the AP with the given json dict in the info pane

  $('#info_title').text(dict.apname);

  if (dict.connections != null) {
    $('#info_wrapper div').each(function(){
      $(this).css('display', 'inline');
    })
    $('#unavailable').css('display', 'none');

    $('#ap_hostname span').text(dict.hname);
    $('#ap_connections span').text(dict.connections);
    $('#ap_uptime span').text(dict.uptime);
    $('#r0_channel span').text(dict.r0_info.channel);
    $('#r1_channel span').text(dict.r1_info.channel);

    if (dict.r0_info.signal != null) {
      $('#r0_signal span').text(dict.r0_info.signal + " dBm");
      $('#r0_quality span').text(dict.r0_info.quality + "%");    
    } else {
      $('#r0_signal span').text("No connections");
      $('#r0_quality').css('display', 'none');
    }

    if (dict.r1_info.signal != null) {
      $('#r1_signal span').text(dict.r1_info.signal + " dBm");
      $('#r1_quality span').text(dict.r1_info.quality + "%");    
    } else {
      $('#r1_signal span').text("No connections");
      $('#r1_quality').css('display', 'none');
    }
  } else {
    $('#info_wrapper div').each(function(){
      $(this).css('display', 'none');
    })
    $('#unavailable').css('display','inline');
  }
}

function goToAPSite (hostname) {
  if (document.getElementById('menu_wrapper').style.display == 'none') {
    window.open(hostname);
  }
}

function checkFields (form) {
  // form is a string representing a CSS ID selector
  $('#' + form + ' input[type=submit]').each(function () {
    $(this).removeAttr('disabled');
  });

  $('#' + form + ' input[type=text]').each(function () {
    if ($(this)[0].value == "") {
      $('#' + form + ' input[type=submit]').each(function () {
        if (!this.classList.contains('always_enabled')) {
          $(this).attr('disabled','disabled');
        }
      });
    }
  });
}
