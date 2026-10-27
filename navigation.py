"""Navigation service helpers."""
from astar import astar
from dynamic_rerouting import shortest_route
from graph_data import ROOMS

def room_destination(room_name):
    if room_name not in ROOMS:
        raise ValueError(f"Unknown room: {room_name}")
    door=ROOMS[room_name].get("door")
    if not door:
        raise ValueError(f"{room_name} is an area, not a destination room.")
    return door

def route_to_room(start_node, room_name, blocked_nodes=None, blocked_edges=None):
    destination=room_destination(room_name)
    if blocked_nodes or blocked_edges:
        result=shortest_route(start_node,destination,blocked_nodes,blocked_edges)
    else:
        result=astar(start_node,destination)
        result["message"]="Route calculated." if result["path"] else "No route is available."
    result["destination_room"]=room_name
    result["destination_node"]=destination
    return result
