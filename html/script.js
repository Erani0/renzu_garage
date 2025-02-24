var CurrentVehicle = {};
var CurrentVehicle_ = {};
var VehicleArr = []
var garage_id = undefined
var currentcar
var chopper = false
var inGarageVehicle = {}
var impound_left = '0'
var isimpounder = false
var impound_fine = 0
var impound_loc = 0
function getTimeRemaining(endtime) {
    const total = Date.parse(endtime) - Date.parse(new Date());
    const seconds = Math.floor((total / 1000) % 60);
    const minutes = Math.floor((total / 1000 / 60) % 60);
    const hours = Math.floor((total / (1000 * 60 * 60)) % 24);
    const days = Math.floor(total / (1000 * 60 * 60 * 24));
    
    return {
      total,
      days,
      hours,
      minutes,
      seconds
    };
  }
  
  function initializeClock(id, endtime) {
    const clock = document.getElementById(id);
    const daysSpan = clock.querySelector('.days');
    const hoursSpan = clock.querySelector('.hours');
    const minutesSpan = clock.querySelector('.minutes');
    const secondsSpan = clock.querySelector('.seconds');
  
    function updateClock() {
      const t = getTimeRemaining(endtime);
  
      daysSpan.innerHTML = t.days;
      hoursSpan.innerHTML = ('0' + t.hours).slice(-2);
      minutesSpan.innerHTML = ('0' + t.minutes).slice(-2);
      secondsSpan.innerHTML = ('0' + t.seconds).slice(-2);
  
      if (t.total <= 0) {
        clearInterval(timeinterval);
      }
    }
  
    updateClock();
    const timeinterval = setInterval(updateClock, 1000);
  }

window.addEventListener('message', function(event) {
    var data = event.data;
    if (event.data.type == "returnveh") {
        returnveh();
    }
    if (event.data.type == "cleanup") {
        cleanup()
    }
    if (event.data.type == "onimpound") {
        impound_loc = event.data.garage
        impound_fine = event.data.fee
        onimpound();
        if (document.getElementById("impoundloc")) {
            document.getElementById("impoundloc").innerHTML = impound_loc;
        }
        if (document.getElementById("fineamount")) {
            document.getElementById("fineamount").innerHTML = impound_fine;
        }
    }
    if (event.data.garage_id) {
        garage_id = event.data.garage_id
    }
    if (event.data.type == "ownerinfo") {
        impound_left = '0'
        impound_fine = 0
        var utcSeconds = event.data.impound_data.date || (Date.now() + 3600000) / 1000;
        var impound_data = event.data.impound_data || {reason: 'No Reason', impounder: 'bobo', duration: 0, fine: 10000};
        var duration_left = (utcSeconds * 1000) + impound_data.duration * 3600000
        impound_fine = impound_data.fine
        const milliseconds = utcSeconds * 1000 // 1575909015000
        const dateObject = new Date(milliseconds)
        const humanDateFormat = dateObject.toLocaleString()
        isimpounder = event.data.job
        if (Date.now() < duration_left && !event.data.job) {
            const impound_epoch = duration_left
            impound_left = duration_left
            //impound_left = impound_left.replace(",", "")
        }
        document.getElementById("dateissue").innerHTML = humanDateFormat;
        for(var [key,value] of Object.entries(data.info)){
            for(var [k,v] of Object.entries(value)){
                if (k == 'firstname') {
                    document.getElementById("ownerinfo").innerHTML = ''+v+' '+value.lastname+'';
                }
                if (k == 'phone_number') {
                    document.getElementById("contact").innerHTML = v;
                }
                if (k == 'job') {
                    document.getElementById("job").innerHTML = v;
                }
            }     
        }
        document.getElementById("reason").innerHTML = impound_data.reason || 'not specified';
        document.getElementById("impounder").innerHTML = impound_data.impounder || 'not specified';
        document.getElementById("duration").innerHTML = impound_data.duration || 'not specified';
        document.getElementById("fine").innerHTML = impound_data.fine || 'not specified';
    }
    if (event.data.chopper) {
        chopper = true
    }
    if (event.data.type == "stats") {
        if (event.data.show) {
            document.getElementById("perf").style.display = 'block';
            if (!event.data.public) {
                document.getElementById("seemod").style.display = 'block';
            }
            for(var [k,v] of Object.entries(event.data.perf)){
                if (k =='name' || k =='plate' || k =='turbo') {
                    if (v == 'Not Installed') {
                        document.getElementById(k).style.color = 'grey';
                    } else if (v == 'Installed') {
                        document.getElementById(k).style.color = 'lime';
                    }
                    document.getElementById(k).innerHTML = v;
                } else {
                    document.getElementById(k).style.width = ''+v+'%';
                }
            }
        } else {
            document.getElementById("perf").style.display = 'none';
            document.getElementById("seemod").style.display = 'none';
        }
    }
    if (event.data.type == "impoundform") {
        var impounds = event.data.data.impounds
        var durations = event.data.data.duration
        $("#impounds").html('')
        $("#impound_duration").html('')
        for (const i in impounds) {
            $("#impounds").append(`<option value="`+impounds[i].garage+`">`+impounds[i].name+`</option>`)
        }
        for (const i in durations) {
            $("#impound_duration").append(`<option value="`+durations[i]+`">`+durations[i]+` Hours</option>`)
        }
        document.getElementById("impoundform").style.display = 'block';
    }

    if (event.data.type == "vehiclekeys") {
        var vehicles = event.data.data.vehicles
        var playersnearby = event.data.data.players
        var current = event.data.data.current
        $("#vehiclelist").html('')
        $("#playerslist").html('')
        $("#formidvehicle").html('')
      var givekey = `<form method="post" id="new_post" name="new_post"  action="" class="wpcf7-form" enctype="mu ltipart/form-data">
        <div class="form-body">
          <div class="spacer-b30">
          <div class="tagline"><span>Give or Share vehicle key to Nearby Citizen</span></div><!-- .tagline -->
          </div>
          <div class="section">
              <label class="field select">
                  <select id="playerslist" name="playerslist">
                      <option value="">Select Citizen</option>
                  </select>
                  <i class="arrow double"></i>                    
              </label>  
          </div><!-- end section -->            
          
          <div class="section">
            <label class="field select">
                <select id="vehiclelist" name="vehiclelist">
                    <option value="">Select Vehicle</option>
                </select>
                <i class="arrow double"></i>                    
            </label>  
        </div><!-- end section -->
          
        </div><!-- end .form-body section -->
        <div class="form-footer">
          <button type="submit" class="button btn" style = "color:white; background-color: rgb(255, 1, 1);" id="give_vehkey"> Transfer Vehicle </button>
          <button type="submit" class="button btn" style = "color:white; background-color: rgb(17, 209, 155);color:grey;" id="dupe_vehkey"> Share Keys </button>
          <button type="reset" class="button" id="cancel_vehkeys"> Cancel </button>
        </div><!-- end .form-footer section -->
      </form>`
      $("#formidvehicle").append(givekey)
        if (current) {
            $("#vehiclelist").html('')
            document.getElementById("dupe_vehkey").style.display = 'inline-block';
            $("#vehiclelist").append(`<option value="`+current.plate+`">Current `+current.name+` [`+current.plate+`] Key</option>`)
        } else {
            document.getElementById("dupe_vehkey").style.display = 'none';
        }
        for (const i in playersnearby) {
            console.log(playersnearby[i],i,playersnearby[i].identifier)
            $("#playerslist").append(`<option value="`+playersnearby[i].identifier+`">`+playersnearby[i].name+` - [`+playersnearby[i].source+`]</option>`)
        }
        for (const i in vehicles) {
            $("#vehiclelist").append(`<option value="`+vehicles[i].plate+`">`+vehicles[i].name+` [`+vehicles[i].plate+`] Key</option>`)
        }
        document.getElementById("give_vehkey").addEventListener("click", function(event){
            var datagive = {}
            for (const i in $( "form" ).serializeArray()) {
                var data = $( "form" ).serializeArray()
                console.log($( "form" ).serializeArray(),data[i].name)
                datagive[data[i].name] = data[i].value
                console.log()
            }
            document.getElementById("vehiclekeys").style.display = 'none';
            $.post("https://renzu_garage/receive_vehiclekeys", JSON.stringify({ action: 'give', data: datagive}));
        });
        document.getElementById("dupe_vehkey").addEventListener("click", function(event){
            var datagive = {}
            for (const i in $( "form" ).serializeArray()) {
                var data = $( "form" ).serializeArray()
                console.log($( "form" ).serializeArray(),data[i].name)
                datagive[data[i].name] = data[i].value
                console.log()
            }
            document.getElementById("vehiclekeys").style.display = 'none';
            $.post("https://renzu_garage/receive_vehiclekeys", JSON.stringify({ action: 'dupe', data: datagive}));
        });
        document.getElementById("cancel_vehkeys").addEventListener("click", function(event) {
            document.getElementById("vehiclekeys").style.display = 'none';
            $.post("https://renzu_garage/receive_vehiclekeys", JSON.stringify({ garagekeysdata: 'cancel' }));
        });
        document.getElementById("vehiclekeys").style.display = 'block';
    }

    if (event.data.type == "garagekeys") {
        var garages = event.data.data.garages
        var mykeys = event.data.data.mykeys
        var action = event.data.data.action
        var playersnearby = event.data.data.players
        $("#garages").html('')
        $("#mygaragekeys").html('')
        $("#formid").html('')
        var managekey = `<form method="post" id="use" name="new_post"  action="" class="wpcf7-form" enctype="mu ltipart/form-data">
        <div class="form-body">
          <div class="spacer-b30">
          <div class="tagline"><span>Garage Data</span></div><!-- .tagline -->
          </div>
          <div class="section" style="display:none;">
              <label class="field select">
                  <select id="garages" name="garages">
                      <option value="">Select Garage Location...</option>
                  </select>
                  <i class="arrow double"></i>                    
              </label>  
          </div><!-- end section -->            
          
          <div class="section">
            <label class="field select">
                <select id="mygaragekeys" name="mygaragekeys">
                    <option value="">Select Keys</option>
                </select>
                <i class="arrow double"></i>                    
            </label>  
        </div><!-- end section -->
          
        </div><!-- end .form-body section -->
        <div class="form-footer">
            <button type="submit" class="button btn-primary" id="use_key"> Use </button>
            <button type="submit" class="button btn-primary" style="background:red;" id="del_key"> Delete </button>
          <button type="reset" class="button" id="cancel_keys"> Cancel </button>
        </div><!-- end .form-footer section -->
      </form>`
      var givekey = `<form method="post" id="new_post" name="new_post"  action="" class="wpcf7-form" enctype="mu ltipart/form-data">
        <div class="form-body">
          <div class="spacer-b30">
          <div class="tagline"><span>Nearby Citizen</span></div><!-- .tagline -->
          </div>
          <div class="section">
              <label class="field select">
                  <select id="playerslist" name="playerslist">
                      <option value="">Select Citizen</option>
                  </select>
                  <i class="arrow double"></i>                    
              </label>  
          </div><!-- end section -->            
          
          <div class="section">
            <label class="field select">
                <select id="garages" name="garages">
                    <option value="">Select Garage</option>
                </select>
                <i class="arrow double"></i>                    
            </label>  
        </div><!-- end section -->
          
        </div><!-- end .form-body section -->
        <div class="form-footer">
          <button type="submit" class="button btn" style = "color:white; background-color: rgb(47, 109, 255);" id="give_key"> Transfer Vehicle </button>
          <button type="reset" class="button" id="cancel_keys"> Cancel </button>
        </div><!-- end .form-footer section -->
      </form>`
      if (action == 'manage') {
        $("#formid").append(managekey)
        for (const i in garages) {
            $("#garages").append(`<option value="`+garages[i].garage+`">Garage `+garages[i].garage+`</option>`)
        }
        for (const i in mykeys) {
            $("#mygaragekeys").append(`<option value="`+mykeys[i].identifier+`">`+mykeys[i].name+` Key</option>`)
        }
        document.getElementById("use_key").addEventListener("click", function(event){
            var givedata = {}
            for (const i in $( "#use" ).serializeArray()) {
                var data = $( "#use" ).serializeArray()
                givedata[data[i].name] = data[i].value
            }
            document.getElementById("garagekeys").style.display = 'none';
            $.post("https://renzu_garage/receive_garagekeys", JSON.stringify({ action: 'use', data: givedata}));
        });
        document.getElementById("del_key").addEventListener("click", function(event){
            var givedata = {}
            for (const i in $( "#use" ).serializeArray()) {
                var data = $( "#use" ).serializeArray()
                givedata[data[i].name] = data[i].value
            }
            document.getElementById("garagekeys").style.display = 'none';
            $.post("https://renzu_garage/receive_garagekeys", JSON.stringify({ action: 'del', data: givedata}));
        });
        
        document.getElementById("cancel_keys").addEventListener("click", function(event) {
            document.getElementById("garagekeys").style.display = 'none';
            $.post("https://renzu_garage/receive_garagekeys", JSON.stringify({ garagekeysdata: 'cancel' }));
        });
      } else {
        $("#formid").append(givekey)
        for (const i in playersnearby) {
            console.log(playersnearby[i],i,playersnearby[i].identifier)
            $("#playerslist").append(`<option value="`+playersnearby[i].identifier+`">`+playersnearby[i].name+` - [`+playersnearby[i].source+`]</option>`)
        }
        for (const i in garages) {
            $("#garages").append(`<option value="`+garages[i].garage+`">Garage `+garages[i].garage+` Key</option>`)
        }
        document.getElementById("give_key").addEventListener("click", function(event){
            var datagive = {}
            for (const i in $( "form" ).serializeArray()) {
                var data = $( "form" ).serializeArray()
                console.log($( "form" ).serializeArray(),data[i].name)
                datagive[data[i].name] = data[i].value
                console.log()
            }
            document.getElementById("garagekeys").style.display = 'none';
            $.post("https://renzu_garage/receive_garagekeys", JSON.stringify({ action: 'give', data: datagive}));
        });
        document.getElementById("cancel_keys").addEventListener("click", function(event) {
            document.getElementById("garagekeys").style.display = 'none';
            $.post("https://renzu_garage/receive_garagekeys", JSON.stringify({ garagekeysdata: 'cancel' }));
        });
      }
        document.getElementById("garagekeys").style.display = 'block';
    }
    if (event.data.type == "cats") {
        var cats = event.data.cats
        for (const i in cats) {
            var img = i
            if (img == 'SPORTS CLASSIC') {
                img = 'SPORTSCLASSIC'
            }
            var gago = `<div class="uk-visible-toggle" tabindex="-1">
            <div class="uk-margin uk-card uk-card-default uk-card-hover">
            <!-- UIkit CARD BODY -->
            <div class="uk-card-body">
            <a class="uk-link-reset uk-position-cover" href="#"></a>
            <div class="uk-flex uk-flex-center">
            <span class="uk-icon default" style="background: url(img/CAR_`+img+`.png);
            background-size: cover;
            width: 100px;
            height: 100px;"></span>
            <span class="uk-icon hover" style="background: url(img/CAR_`+img+`.png);
            background-size: cover;
            width: 100px;
            height: 100px;"></span>
            </div>
            <h3 class="uk-card-title uk-margin">`+ i +`</h3>
            </div>
            <!-- UIkit CARD FOOTER DEFAULT -->
            <div class="uk-card-footer default">
            <p>`+cats[i]+` Vehicles</p>
            </div>
            <!-- UIkit CARD FOOTER HOVER -->
            <div class="uk-card-footer uk-hidden-hover">
            <nav class="uk-navbar-container uk-navbar-transparent" uk-navbar>
            <div class="uk-navbar-center uk-navbar-item">
            <ul class="uk-navbar-nav">
            <li><a onclick="choosecat('`+i+`')" class="tooltip-top" href="#" data-tooltip="Select this"><span class="uk-icon uk-margin-small-right"><i class="far fa-eye"></i></span>Select</a></li>
            <li><a class="tooltip-top" href="#" data-tooltip="Total: `+cats[i]+`"><span class="uk-icon uk-margin-small-right"><i class="fas fa-archive"></i></span>Vehicles</a></li>
            </ul>
            </div>
            </nav>
            </div>
            </div>
            </div>`
            $("#vehicle_cat").append(gago)
        }
    }
    if (event.data.type == "display") {
        garage_id = event.data.garage_id
        chopper = false
        if (event.data.chopper) {
            chopper = true
        }
        VehicleArr = undefined
        currentcar = undefined;
        VehicleArr = [];
        CurrentVehicle = [];
        $("#garage").fadeIn();
        for(var [key,value] of Object.entries(data.data)){   
            for(var [k,v] of Object.entries(value)){
                VehicleArr.push(v);          
            }             
        }
        OpenGarage(VehicleArr)
        ShowVehicle(0);
        $("#appdiv").css("display","block")
        if (!event.data.view) {
            $("#appdiv").css("right","0")
        }
    }

    if (event.data.type == "hide") {
        $("#garage").fadeOut();
    }

    if (event.data.type == "notify") {       
        var data = event.data;

        $("#messagePopup").css("background-color","rgb(252, 0, 0)");      

        $("#messagePopup").fadeIn(500);      
        
        $('#messagePopup').append(`

        <span>`+ data.message +`</span>    
        
        `)
        
        setTimeout(function(){ $("#messagePopup").fadeOut(500);         document.getElementById("messagePopup").innerHTML = ''; }, 3000);

    }

});

function choosecat(i) {
    $("#vehicle_cat").html('')
    $.post("https://renzu_garage/choosecat", JSON.stringify({ cat: i }));
}

document.getElementById("confirm_impound").addEventListener("click", function(event){
    var impound_data = {}
    for (const i in $( "form" ).serializeArray()) {
        var data = $( "form" ).serializeArray()
        impound_data[data[i].name] = data[i].value
    }
    document.getElementById("impoundform").style.display = 'none';
    $.post("https://renzu_garage/receive_impound", JSON.stringify({ impound_data: impound_data }));
});

document.getElementById("cancel_impound").addEventListener("click", function(event) {
    document.getElementById("impoundform").style.display = 'none';
    $.post("https://renzu_garage/receive_impound", JSON.stringify({ impound_data: 'cancel' }));
});

$(document).ready(function() {
    $('.upper-bottom-container').on('afterChange', function(event, slick, currentSlide) {
        
        $('.button-container').appendTo(currentSlide);
    });

    var app = '<div class="container">\
    <div class="right">\
      <div style="display:none;" class="app" id="appdiv">\
      <div style="\
    padding: 10px;\
    background: #222;\
    /* width: 100%; */\
    color: #fefefe;\
"><input id="SearchData" oninput="Search()" placeholder="Search - Plate, Model, Brand, Category" type="text" style="\
    color: #a2a5a9;\
    width: 100%;\
    border-radius: 5px;\
    height: 25px;\
    background: #505356;\
    text-align: center;\
"></div>\
        <div class="app_inner" id="vehlist">\
        </div>\
      </div>\
    </div>\
  <div id="closemenu" class="modal" style="background-color:#050505c5 !important; color:#fff;">\
  </div>\
  <div class="middle-left-container">\
      <div class="column" id="vehicleclass"> \
      </div>\
      <div class="column" id="nameBrand">\
      </div>\
      <div class="column menu-modifications" style="right:50px; position:absolute;top:-20px;">\
          <div class="row" id="confirm"> <button class="confirm_out" style="background:#24262773;color:#fff !important; border-radius: 10px;" onclick="garage()"> <i class="fad fa-garage"></i> Go to Garage </button> </div>\
      </div>\
  </div>\
  <div class="middle-left2-container">\
      <div class="column" id="contentVehicle">\
      </div>\
  </div>\
  <div id="messagePopup">\
  </div>\
  <div class="bottom-container"></div>\
  <div class="top-triangle"></div>\
</div>'

$('#garage').append(app);
});

function ShowVehicle(currentTarget) {
        var data = inGarageVehicle[currentTarget]
        if (data && currentcar !== currentTarget) {
            currentcar = currentTarget
            var div = $(this).parent().find('.active');        
            $(div).removeClass('active');
            var itemDisabled = false;
            if (garage_id == undefined) {
                garage_id = 'A'
            }
            if(!itemDisabled && garage_id.search("impound") == -1) {
                $(currentTarget).addClass('active');
                $('.modal').css("display","none");
                
                if (document.getElementById("nameBrand")) {
                    document.getElementById("nameBrand").innerHTML = '';
                }
                if (document.getElementById("vehicleclass")) {
                    document.getElementById("vehicleclass").innerHTML = '';
                }
                if (document.getElementById("contentVehicle")) {
                    document.getElementById("contentVehicle").innerHTML = '';
                }
                if (document.getElementById("vehicleclass")) {
                    document.getElementById("vehicleclass").innerHTML = ' <img id="vehicle_class_image" src="https://forum.cfx.re/uploads/default/original/4X/b/1/9/b196908c7e5dfcd60aa9dca0020119fa55e184cb.png">';
                }     

                if (data.brand && data.name) {
                    $('#nameBrand').append(`
                    <span id="vehicle_class">`+data.brand+`</span> 
                    <span id="vehicle_name">`+data.name+`</span> 
                    `);
                }

                $(".menu-modifications").css("display","block");

                CurrentVehicle = {brand: data.brand || 'Sports', modelcar: data.model2 || -1, sale: 1, name: data.name || 'Vehicle',  plate: data.plate }
                $('#contentVehicle').append(`
                    <div class="row spacebetween">
                        <span class="title">HANDLING</span>
                        <span>`+data.handling.toFixed(1)+`</span>
                    </div>

                    <div class="row">
                    <div class="w3-border" style="width: 100%;
                    margin-left: 10px;"> <div class="w3-grey" style="height:5px;width:`+data.handling.toFixed(1)/10*100+`%"></div> </div>
                    </div>

                    <div class="row spacebetween">
                        <span class="title">TOP SPEED</span>
                        <span>`+data.topspeed.toFixed(0)+` KM/H</span>
                    </div>

                    <div class="row">
                    <div class="w3-border" style="width: 100%;
                    margin-left: 10px;"> <div class="w3-grey" style="height:5px;width:`+data.topspeed.toFixed(1)/520*100+`%"></div> </div>
                    </div>

                    <div class="row spacebetween">
                        <span class="title">HORSE POWER</span>
                        <span>`+data.power.toFixed(0)+` HP</span>
                    </div>

                    <div class="row">
                    <div class="w3-border" style="width: 100%;
                    margin-left: 10px;"> <div class="w3-grey" style="height:5px;width:`+data.topspeed.toFixed(1)/500*100+`%"></div> </div>
                    </div>

                    <div class="row spacebetween">
                        <span class="title">TORQUE</span>
                        <span>`+data.torque.toFixed(0)+` TQ</span>
                    </div>

                    <div class="row">
                    <div class="w3-border" style="width: 100%;
                    margin-left: 10px;"> <div class="w3-grey" style="height:5px;width:`+data.torque.toFixed(1)/500*100+`%"></div> </div>
                    </div>

                    <div class="row spacebetween">
                        <span class="title">BRAKE</span>
                        <span>`+data.brake.toFixed(1)+`</span>
                    </div>

                    <div class="row">
                    <div class="w3-border" style="width: 100%;
                    margin-left: 10px;"> <div class="w3-grey" style="height:5px;width:`+data.brake.toFixed(1)/2*100+`%"></div> </div>
                    </div>
                `);
                if (chopper) {
                    $.post("https://renzu_garage/SpawnChopper", JSON.stringify({ modelcar: data.model2, price: 1,  plate: data.plate }));
                } else {
                    $.post("https://renzu_garage/SpawnVehicle", JSON.stringify({ modelcar: data.model2, price: 1,  plate: data.plate }));
                }
            } else if(!itemDisabled && garage_id.search("impound") !== -1) {
                $(currentTarget).addClass('active');         
                $('.vehiclegarage').animate({scrollLeft:scrollAmount}, 'fast');

                $('.modal').css("display","none");

                if (document.getElementById("nameBrand")) {
                    document.getElementById("nameBrand").innerHTML = '';
                }
                if (document.getElementById("vehicleclass")) {
                    document.getElementById("vehicleclass").innerHTML = '';
                }
                if (document.getElementById("contentVehicle")) {
                    document.getElementById("contentVehicle").innerHTML = '';
                }
                if (document.getElementById("vehicleclass")) {
                    document.getElementById("vehicleclass").innerHTML = ' <img id="vehicle_class_image" src="https://forum.cfx.re/uploads/default/original/4X/b/1/9/b196908c7e5dfcd60aa9dca0020119fa55e184cb.png">';
                }

                if (data !== undefined && data.brand !== undefined && data.name !== undefined) {
                    $('#nameBrand').append(`
                        <span id="vehicle_class">`+data.brand+`</span> 
                        <span id="vehicle_name">`+data.name+`</span> 
                    `);
                }

                $(".menu-modifications").css("display","block");
                if (data == undefined) {
                    data = {}
                }
                if (data.brand == undefined) {
                    data.brand = 'Unknown'
                }
                CurrentVehicle = {brand: data.brand || 'Sports', modelcar: data.model2 || -1, sale: 1, name: data.name || 'Vehicle',  plate: data.plate }
                $('#contentVehicle').append(`
                    <div class="handling-container">
                        <span>Impound Data</span>
                        <div class="handling-bar-container">
                        <div class="handling-line"></div>
                        <div class="handling-circle" style="left: 100%;"></div>
                    </div>
 

                    </div>

                    <div class="row spacebetween">
                        <span class="title">Officer in charge: </span>
                        <span id="impounder">Boy Ulol</span>
                    </div>
                    
                    <div class="row spacebetween">
                        <span class="title">Reason: </span>
                        <span id="reason">Bobo</span>
                    </div>
                    
                    <div class="row spacebetween">
                        <span class="title">Owners name</span>
                        <span id="ownerinfo">Boy Ulol</span>
                    </div>

                    <div class="row spacebetween">
                        <span class="title">CONTACT #</span>
                        <span id="contact">No Specified</span>
                    </div>

                    <div class="row spacebetween">
                        <span class="title">JOB</span>
                        <span id="job">Mafia</span>
                    </div>

                    <div class="row spacebetween">
                        <span class="title">Duration: </span>
                        <span id="duration">3:45</span>
                    </div>

                    <div class="row spacebetween">
                        <span class="title">DATE ISSUE</span>
                        <span id="dateissue">1/11/1111</span>
                    </div>

                    <div class="row spacebetween">
                        <span class="title">Fine</span>
                        <span id="fine">$ 4000.0</span>
                    </div>
                `);
                $.post("https://renzu_garage/ownerinfo", JSON.stringify({ plate: data.plate, identifier: data.identifier, chopstatus: 1 }));
                $.post("https://renzu_garage/SpawnVehicle", JSON.stringify({ modelcar: data.model2, price: 1, plate: data.plate }));
            }
        }
}
function garage() {
    $.post("https://renzu_garage/gotogarage", JSON.stringify({id: garage_id }));
}

function ShowConfirm(){
    document.getElementById("closemenu").innerHTML = '';
    $("#vehicle_cat").html('')

    $('.modal').css("display","flex");
    if (impound_left !== '0') {
        
        $('#closemenu').append(`
        <div class="background-circle"></div>
        <div class="modal-content">
            <i style="    position: absolute;
            right: 20%;
            font-size: 30px; top:-2px;" class="fas fa-garage-car"></i>
            <p class="title">Impound:</p>
            <p class="vehicle">Vehicle is Unavailable</p>
        </div>

        <div class="modal-footer" style="display:inline-block !important; text-align:center;margin:20px;">
            <h1 style="font-size:12px;">Release Date</h1>
            <div id="clockdiv">
            <div>
                <span class="days"></span>
                <div class="smalltext">Days</div>
            </div>
            <div>
                <span class="hours"></span>
                <div class="smalltext">Hours</div>
            </div>
            <div>
                <span class="minutes"></span>
                <div class="smalltext">Minutes</div>
            </div>
            <div>
                <span class="seconds"></span>
                <div class="smalltext">Seconds</div>
            </div>
            </div>
            </div>
        `);
        const deadline = new Date(impound_left);
        initializeClock('clockdiv', deadline);
          //# sourceURL=pen.js
    } else {
        $('#closemenu').append(`
        <div class="background-circle"></div>
        <div class="modal-content">
            <i style="    position: absolute;
            right: 20%;
            font-size: 30px; top:-2px;" class="fas fa-garage-car"></i>
            <p class="title">Confirm:</p>
            <p class="vehicle">Release Vehicle</p>
            <p style="display:none;" id="finediv">FINE: $ <span id="fineamount">0</span></p>
        </div>

        <div class="modal-footer">
            <div class="modal-buttons">     
                <div>
                    <span>Use</span>
                    <button id="money" class="modal-money button" onclick="GetVehicle('confirm')" >✔️</button>
                </div>
                <div>
                    <span>Cancel</span>
                    <button href="#!" id="card" class="modal-money button" onclick="GetVehicle('cancel')">X</button>
                </div>
            </div>
        </div>
        `);
        document.getElementById("finediv").style.display = 'none';
        if (!isimpounder && impound_fine > 0) {
            document.getElementById("fineamount").innerHTML = impound_fine;
            document.getElementById("finediv").style.display = 'block';
        }
    }
    
}

function returnveh(){    
    document.getElementById("closemenu").innerHTML = '';
    $("#vehicle_cat").html('')

    $('.modal').css("display","flex");

    $('#closemenu').append(`
        <div class="background-circle"></div>
        <div class="modal-content">
            <p class="vehicle">Vehicle is outside of garage! - Do you Want to Deliver Here?</p>
        </div>

        <div class="modal-footer">
            <div class="modal-buttons">     
                <div>
                    <span>Pay</span>
                    <button id="money" class="modal-money button" onclick="returnvehicle('confirm')" >✔️</button>
                </div>
                <div>
                    <span>Cancel</span>
                    <button href="#!" id="card" class="modal-money button" onclick="returnvehicle('cancel')">X</button>
                </div>
            </div>
        </div>
    `);
}

function onimpound(){    
    document.getElementById("closemenu").innerHTML = '';
    $("#vehicle_cat").html('')

    $('.modal').css("display","flex");

    $('#closemenu').append(`

        <div class="background-circle"></div>
        <div class="modal-content">
            <i style="    position: absolute;
            right: 20%;
            font-size: 30px; top:-2px;" class="fas fa-garage-car"></i>
            <p class="title">Impound:</p>
            <p class="vehicle">Vehicle is Impounded</p>
        </div>

        <div class="modal-footer">
            <p style="font-size: 12px;
            color: red;
            display: block;
            margin: 20px;
            text-align: center;
            position: absolute;
            top: 50%;
            background: #101113c7;
            padding: 20px;
            border-radius: 10px;"> Require to Pay at <span id="impoundloc" style="color:#ffffff !important;"></span>: <br> <br>
            Fine $ `+impound_fine+`</p>
        </div>
    `);
}

function GetVehicle(option) {
    if (chopper) {
        $('.modal').css("display","none");
        VehicleArr = []
        switch(option){
            case 'cancel':
                break;
            case 'confirm':
                $.post('https://renzu_garage/flychopper', JSON.stringify(CurrentVehicle));
                CurrentVehicle_ = CurrentVehicle
                CurrentVehicle = {}
                break;
        }
    } else {
        $('.modal').css("display","none");
        VehicleArr = []
        switch(option){
            case 'cancel':
                break;
            case 'confirm':
                $.post('https://renzu_garage/GetVehicleFromGarage', JSON.stringify(CurrentVehicle));
                CurrentVehicle_ = CurrentVehicle
                CurrentVehicle = {}
                break;
        }
    }  
}

function returnvehicle(option) {
    $('.modal').css("display","none");
    VehicleArr = []
    switch(option){
        case 'cancel':
            break;
        case 'confirm':
            $.post('https://renzu_garage/ReturnVehicle', JSON.stringify(CurrentVehicle_));
            CurrentVehicle_ = {}
            break;
    }
}

function cleanup() {
    document.getElementById("vehlist").innerHTML = '';
}

var scrollAmount = 0

$(document).on('keydown', function(event) {
    switch(event.keyCode) {
        case 27: // ESC
            VehicleArr = []
            CurrentVehicle = {}
            $("#vehicle_cat").html('')
            impound_left = '0'
            setTimeout(function(){ window.location.reload(false);  }, 500);
            $.post('https://renzu_garage/Close');  
            break;
        case 9: // TAB
            break;
        case 17: // TAB
            break;
    }
});
    Renzu_Garage = {};
    inGarageVehicle = {}
    function OpenGarage(data) {
        $('.vehiclegarage').empty();
        $('.app_inner').empty();
        if (document.getElementById("vehlist")) {
            document.getElementById("vehlist").innerHTML = '';
        }
        for(i = 0; i < (data.length); i++) {
            var modelUper = data[i].model;
            inGarageVehicle[i] = data[i]
            var img = data[i].img
            var plate = data[i].plate.replace(' ','');
            var cats = data[i].brand.replace(' ','');
            var name = data[i].name.replace(' ','');
            $(".app_inner").append('<content class="datas" data-'+modelUper.toLowerCase()+''+plate.toLowerCase()+''+cats.toLowerCase()+''+name.toLowerCase()+'="'+modelUper+' '+data[i].plate+' '+data[i].brand+'"><label style="cursor:pointer;"><input false="" id="tab-'+ i +'" onclick="ShowVehicle('+i+')" name="buttons" type="radio"> <label for="tab-'+ i +'"> <div class="app_inner__tab"> <span style="position:absolute;top:4px;left:8px;font-size:7px;color: #e2e2e2;;">Category: '+ data[i].brand +'</span> <span style="position:absolute;top:4px;right:5px;font-size:8px;color:#fefefe;">Garage: '+ data[i].garage_id +'</span><h2 style="font-size:11px !important;"> <i class="icon" style="right:100px;"><img style="height:20px;" src="https://cdn.discordapp.com/attachments/709992715303125023/813351303887192084/wheel.png"></i> '+ data[i].name +' - Plate: '+ data[i].plate +' </h2> <div class="tab_left"> <i class="big icon"><img class="imageborder" style="min-width: 120px;height: 70px;border-radius: 10px;max-width: 120px;border-color: #c7c7c7;padding:2px;background:#d2dce266;" onerror="this.src=`https://i.imgur.com/Jdz2ZMK.png`;" src="'+img+'"></i>   </div> <div class="tab_right"> <p>Fuel Level: <div class="w3-border"> <div class="w3-grey" style="height:5px;width:'+ (data[i].fuel) +'%"></div> </div></p> <p>Body  Health: <div class="w3-border"> <div class="w3-grey" style="height:5px;width:'+ (data[i].bodyhealth * 0.1) +'%"></div> </div></p> <p>Engine Health: <div class="w3-border"> <div class="w3-grey" style="height:5px;width:'+ (data[i].enginehealth * 0.1) +'%"></div> </div></p><div class="row" id="confirm"> <button class="confirm_out" style="background:#191b1f87" onclick="ShowConfirm()"> <i class="fad fa-garage-open"></i> Take Out </button> </div> </div> </div> </label></input></label></content>');    
        }     
    }
    $("#garage").fadeOut();

    function Search(string) {
        var val = document.getElementById('SearchData').value
        val = val.replace(' ','')
        var allEl = document.querySelectorAll('.datas');
        var regex = new RegExp('^(.*)'+val+'(.*)$');

        for (var i = 0; i < allEl.length; i++) {
            var data = Object.keys(allEl[i].dataset);
            for (var j = 0; j < data.length; j++) {
                if (!regex.test(data[j])) {
                        allEl[i].style.display = 'none'
                } else {
                    allEl[i].style.display = 'block'
                }
            }
        }
    }