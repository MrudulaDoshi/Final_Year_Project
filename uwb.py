"""Virtual UWB ranging simulator. This is simulation, not physical UWB hardware."""
import math, random
from graph_data import ANCHORS, NAV_NODES, DOORS

def point_for_node(node_id):
    if node_id in NAV_NODES:
        x,y=NAV_NODES[node_id]
    elif node_id in DOORS:
        x,y=DOORS[node_id]
    else:
        raise ValueError(f"Unknown node: {node_id}")
    return x+12.5, y+12.5

def measure_distances(tag_xy, noise_std=0.08, seed=None):
    rng = random.Random(seed)
    x,y=tag_xy
    result={}
    for anchor,(ax,ay) in ANCHORS.items():
        ax+=15; ay+=15
        ideal=math.hypot(x-ax,y-ay)
        result[anchor]=max(0.0,ideal+rng.gauss(0,noise_std))
    return result

def simulate_tag_at_node(node_id, noise_std=0.08, seed=None):
    xy=point_for_node(node_id)
    return {"node":node_id,"position":{"x":xy[0],"y":xy[1]},
            "distances":measure_distances(xy,noise_std,seed)}
