"""Map estimated coordinates to the nearest walkable navigation node."""
from graph_data import NAV_NODES, DOORS

def nearest_node(position, allowed_types=("navigation","door")):
    candidates={}
    if "navigation" in allowed_types:
        candidates.update({k:(x+12.5,y+12.5) for k,(x,y) in NAV_NODES.items()})
    if "door" in allowed_types:
        candidates.update({k:(x+12.5,y+12.5) for k,(x,y) in DOORS.items()})
    if not candidates: raise ValueError("No candidate nodes enabled.")
    x,y=float(position["x"]),float(position["y"])
    node,xy=min(candidates.items(),key=lambda item:(item[1][0]-x)**2+(item[1][1]-y)**2)
    return {"node":node,"x":xy[0],"y":xy[1],
            "error_distance":round(((xy[0]-x)**2+(xy[1]-y)**2)**0.5,2)}
