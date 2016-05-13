/*
	Here lives the slime replicator
	This machine consumes cores to create a slime.
	To create more of these cores, stick the slime core in the extractor.
*/
/obj/machinery/slime/replicator
	name = "Slime replicator"
	desc = "A machine for creating slimes from cores. Amazing!"
	density = 1
	anchored = 1
	circuit = /obj/item/weapon/circuitboard/slimereplicator
	var/obj/item/slime/core/core = null
	var/inuse
	var/occupiedcolor = "#22FF22"
	var/emptycolor = "#FF2222"
	var/operatingcolor = "#FFFF22"
	
/obj/machinery/slime/replicator/map/New()
	..()
	circuit = new circuit(src)
	component_parts = list()
	//Component parts go here,

/obj/machinery/slime/replicator/attackby(var/obj/item/W, var/mob/user)
	//Let's try to deconstruct first.
	if(istype(W, /obj/item/weapon/screwdriver) && !inuse)
		default_deconstruction_screwdriver(user, W)
		return
	
	if(istype(W, /obj/item/weapon/crowbar))
		default_deconstruction_crowbar(user, W)
		return

	var/obj/item/slime/core/G = W
	
	if(!istype(G))
		return ..()
		
	if(core)
		user << "<span class='warning'>The [src] is already filled!</span>"
		return
	if(panel_open)
		user << "<span class='warning'>Close the panel first!</span>"
	core = G
	G.forceMove(src)
	update_light_color()
		
/obj/machinery/slime/replicator/proc/update_light_color()
	if(src.core && !(inuse))
		set_light(4, 4, occupiedcolor)
	else if(src.core)
		set_light(4, 4, operatingcolor)
	else
		set_light(4, 4, emptycolor)
		
/obj/machinery/slime/replicator/proc/extract_cores()
	if(!src.core)
		src.visible_message("\icon[src] [src] pings unhappily.")
	else if(inuse)
		return
		
	inuse = 1
	update_light_color()
	spawn(30)
		var/mob/living/simple_animal/xeno/slime/S = new()
		S.traitdat = core.slimetraits
		S.forceMove(src)
		spawn(30)
			qdel(core)
			inuse = 0
			eject_contents()
			update_light_color()
			
/obj/machinery/slime/replicator/proc/eject_contents()
	for(var/mob/thing in contents)
		thing.forceMove(loc)
	if(core)
		core.forceMove(loc)
		core = null
	
//Circuit board below,
/obj/item/weapon/circuitboard/slimereplicator
	name = T_BOARD("Slime replicator")
	build_path = "/obj/machinery/slime/replicator"
	board_type = "machine"
	origin_tech = list()	//To be filled,
	req_components = list()	//To be filled, 
	