"""Hospital map geometry and walkable graph based only on the supplied map data."""
MAP_WIDTH = 1450
MAP_HEIGHT = 900

ROOMS = {
    "CAFETERIA": {"width":313,"height":120,"left":0,"top":0,"door":"E1"},
    "STAFF ROOM": {"width":291,"height":120,"left":313,"top":0,"door":"E2"},
    "OPD": {"width":336,"height":120,"left":604,"top":0,"door":"E3"},
    "CARDIOLOGY": {"width":260,"height":120,"left":940,"top":0,"door":"E4"},
    "ICU": {"width":250,"height":120,"left":1200,"top":0,"door":"E5"},
    "LABORATORY": {"width":220,"height":110,"left":0,"top":190,"door":"E6"},
    "MRI": {"width":140,"height":130,"left":300,"top":190,"door":"E7"},
    "OPERATION THEATRE": {"width":120,"height":130,"left":440,"top":190,"door":"E8"},
    "ORTHOPEDICS": {"width":190,"height":270,"left":640,"top":190,"door":"E9"},
    "GENERAL WARD": {"width":350,"height":140,"left":980,"top":190,"door":"E10"},
    "RADIOLOGY": {"width":220,"height":120,"left":0,"top":300,"door":"E11"},
    "BLOOD BANK": {"width":220,"height":120,"left":0,"top":420,"door":"E12"},
    "WAITING AREA": {"width":260,"height":140,"left":300,"top":320,"door":"E13"},
    "NURSE STATION": {"width":210,"height":130,"left":980,"top":330,"door":"E14"},
    "MEDICAL RECORDS": {"width":140,"height":130,"left":1190,"top":330,"door":"E15"},
    "CONSULTATION": {"width":220,"height":110,"left":0,"top":540,"door":"E16"},
    "ISOLATION": {"width":160,"height":140,"left":300,"top":510,"door":"E17"},
    "STORE ROOM": {"width":100,"height":140,"left":460,"top":510,"door":"E18"},
    "LIFT": {"width":95,"height":140,"left":640,"top":510,"door":"E19"},
    "STAIRS": {"width":95,"height":140,"left":735,"top":510,"door":"E20"},
    "ULTRASOUND ROOM": {"width":210,"height":140,"left":979,"top":510,"door":"E21"},
    "BLOOD TEST": {"width":140,"height":140,"left":1190,"top":510,"door":"E22"},
    "XRAY ROOM": {"width":200,"height":120,"left":0,"top":780,"door":"E23"},
    "PHARMACY": {"width":280,"height":120,"left":200,"top":780,"door":"E24"},
    "RECEPTION": {"width":110,"height":120,"left":481,"top":780,"door":"E27"},
    "EMERGENCY": {"width":280,"height":120,"left":920,"top":780,"door":"E25"},
    "CT SCAN": {"width":250,"height":120,"left":1200,"top":780,"door":"E26"},
    "HOSPITAL": {"width":1450,"height":900,"left":0,"top":0,"door":"E28"},
    "CORRIDOR": {"width":1450,"height":70,"left":0,"top":120,"door":None},
}

DOORS = {
"E1":(97,94),"E2":(357,95),"E3":(853,94),"E4":(1138,94),"E5":(1396,94),
"E6":(195,217),"E7":(357,190),"E8":(487,190),"E9":(804,351),"E10":(1138,190),
"E11":(195,326),"E12":(195,473),"E13":(405,435),"E14":(980,351),"E15":(1301,382),
"E16":(196,572),"E17":(367,622),"E18":(496,625),"E19":(670,622),"E20":(776,625),
"E21":(1057,625),"E22":(1265,622),"E23":(96,781),"E24":(367,781),"E25":(1057,781),
"E26":(1265,780),"E27":(566,802),"E28":(776,875)
}
NAV_NODES = {
"N1":(97,142),"N2":(248,142),"N3":(357,142),"N4":(487,142),"N5":(593,142),
"N6":(853,142),"N7":(1138,142),"N8":(1396,142),"N9":(248,217),"N10":(248,326),
"N11":(853,351),"N12":(1396,382),"N13":(248,473),"N14":(405,473),"N15":(593,473),
"N16":(853,473),"N17":(1396,473),"N18":(248,572),"N19":(248,703),"N20":(367,703),
"N21":(496,703),"N22":(593,703),"N23":(670,703),"N24":(776,703),"N25":(853,703),
"N26":(1057,703),"N27":(1265,703),"N28":(1396,703),"N29":(776,802)
}
ANCHORS = {
"A1":(185,140),"A2":(640,140),"A3":(1220,140),"A4":(260,383),"A5":(930,530),
"A6":(1340,510),"A7":(150,673),"A8":(610,751),"A9":(1159,740)
}

# Each edge is exactly one of the supplied bidirectional walkable connections.
CONNECTIONS = [
("N1","N2"),("N2","N3"),("N3","N4"),("N4","N5"),("N5","N6"),("N6","N7"),("N7","N8"),
("N2","N9"),("N9","N10"),("N10","N13"),("N13","N18"),("N18","N19"),
("N13","N14"),("N14","N15"),("N15","N16"),("N16","N17"),("N5","N15"),
("N6","N11"),("N11","N16"),("N8","N12"),("N12","N17"),("N17","N28"),
("N19","N20"),("N20","N21"),("N21","N22"),("N22","N23"),("N23","N24"),
("N24","N25"),("N25","N26"),("N26","N27"),("N27","N28"),("N15","N22"),
("N16","N25"),("N24","N29"),
("E1","N1"),("E2","N3"),("E3","N6"),("E4","N7"),("E5","N8"),("E6","N9"),
("E7","N3"),("E8","N4"),("E9","N11"),("E10","N7"),("E11","N10"),("E12","N13"),
("E13","N14"),("E14","N11"),("E15","N12"),("E16","N18"),("E17","N20"),
("E18","N21"),("E19","N23"),("E20","N24"),("E21","N26"),("E22","N27"),
("E23","N19"),("E24","N20"),("E25","N26"),("E26","N27"),("E27","N29"),("E28","N29")
]

def center(pos, size=25):
    """Convert top-left coordinates to object centre coordinates."""
    return (float(pos[0]) + size/2, float(pos[1]) + size/2)

def all_positions():
    points = {}
    points.update({k:center(v) for k,v in NAV_NODES.items()})
    points.update({k:center(v) for k,v in DOORS.items()})
    return points

def build_graph():
    points = all_positions()
    graph = {node: [] for node in points}
    for a,b in CONNECTIONS:
        if a not in points or b not in points:
            raise ValueError(f"Unknown graph node in connection: {a} <-> {b}")
        x1,y1 = points[a]; x2,y2 = points[b]
        distance = ((x2-x1)**2 + (y2-y1)**2)**0.5
        graph[a].append((b,distance))
        graph[b].append((a,distance))
    return graph
