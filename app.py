"""Flask REST API for the UWB hospital navigation simulation."""
from flask import Flask, jsonify, request
from flask_cors import CORS
from graph_data import MAP_WIDTH, MAP_HEIGHT, ROOMS, DOORS, NAV_NODES, ANCHORS, CONNECTIONS, all_positions
from navigation import route_to_room
from tracking import update_tracking, get_tracking
from uwb import simulate_tag_at_node
from trilateration import trilaterate
from position_mapping import nearest_node

app=Flask(__name__)
CORS(app)

@app.get("/")
def home():
    return jsonify({"name":"UWB Hospital Navigation API","mode":"simulation",
                    "health":"/api/health","map":"/api/map","routes":"/api/route"})

@app.get("/api/health")
def health():
    return jsonify({"status":"ok","mode":"simulation"})

@app.get("/api/map")
def get_map():
    return jsonify({"width":MAP_WIDTH,"height":MAP_HEIGHT,"rooms":ROOMS,
        "doors":{k:{"left":v[0],"top":v[1],"width":25,"height":25} for k,v in DOORS.items()},
        "nodes":{k:{"left":v[0],"top":v[1],"width":25,"height":25} for k,v in NAV_NODES.items()},
        "anchors":{k:{"left":v[0],"top":v[1],"width":30,"height":30} for k,v in ANCHORS.items()},
        "connections":[list(edge) for edge in CONNECTIONS]})

@app.get("/api/rooms")
def rooms():
    return jsonify([{"name":name,"door":data.get("door")} for name,data in ROOMS.items() if data.get("door")])

@app.get("/api/route")
def route():
    start=request.args.get("start","N1").upper()
    destination=request.args.get("destination","ICU")
    blocked_nodes=request.args.get("blocked_nodes","")
    blocked_edges=request.args.get("blocked_edges","")
    bn=[x.strip().upper() for x in blocked_nodes.split(",") if x.strip()]
    be=[]
    for pair in blocked_edges.split(","):
        parts=[x.strip().upper() for x in pair.split("-") if x.strip()]
        if len(parts)==2: be.append(parts)
    try:
        result=route_to_room(start,destination,bn,be)
        result["distance_unit"]="map coordinate units"
        return jsonify(result), (200 if result["path"] else 404)
    except ValueError as exc:
        return jsonify({"error":str(exc)}),400

@app.post("/api/simulate")
def simulate():
    body=request.get_json(silent=True) or {}
    node=str(body.get("node","N1")).upper()
    noise=float(body.get("noise_std",0.08))
    try:
        uwb_data=simulate_tag_at_node(node,noise,body.get("seed"))
        estimate=trilaterate(uwb_data["distances"])
        mapped=nearest_node(estimate)
        return jsonify({"actual":uwb_data,"estimated_position":estimate,"mapped_node":mapped})
    except (ValueError,KeyError) as exc:
        return jsonify({"error":str(exc)}),400

@app.post("/api/track")
def track():
    body=request.get_json(silent=True) or {}
    tag_id=str(body.get("tag_id","PATIENT-001"))
    node=str(body.get("node","N1")).upper()
    try: return jsonify(update_tracking(tag_id,node,float(body.get("noise_std",0.08)),body.get("seed")))
    except (ValueError,KeyError) as exc: return jsonify({"error":str(exc)}),400

@app.get("/api/track/<tag_id>")
def track_read(tag_id):
    record=get_tracking(tag_id)
    return (jsonify(record),200) if record else (jsonify({"error":"Tag not found"}),404)

if __name__=="__main__":
    app.run(host="0.0.0.0",port=5000,debug=True)
