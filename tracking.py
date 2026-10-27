"""In-memory simulated patient/tag tracking."""
from datetime import datetime, timezone
from uwb import simulate_tag_at_node
from trilateration import trilaterate
from position_mapping import nearest_node

_TRACKS={}

def update_tracking(tag_id, node_id, noise_std=0.08, seed=None):
    uwb_data=simulate_tag_at_node(node_id,noise_std,seed)
    estimated=trilaterate(uwb_data["distances"])
    mapped=nearest_node(estimated,("navigation","door"))
    record={"tag_id":tag_id,"timestamp":datetime.now(timezone.utc).isoformat(),
            "actual_node":node_id,"actual_position":uwb_data["position"],
            "distances":uwb_data["distances"],"estimated_position":estimated,
            "mapped_position":mapped}
    _TRACKS[tag_id]=record
    return record

def get_tracking(tag_id):
    return _TRACKS.get(tag_id)
