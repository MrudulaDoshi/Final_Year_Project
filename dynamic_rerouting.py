"""Temporary edge/node blocking and route recalculation."""
from graph_data import build_graph, all_positions

def shortest_route(start, goal, blocked_nodes=None, blocked_edges=None):
    import heapq
    blocked_nodes = set(blocked_nodes or [])
    blocked_edges = {frozenset(edge) for edge in (blocked_edges or [])}
    graph = build_graph()
    points = all_positions()
    if start in blocked_nodes or goal in blocked_nodes:
        return {"path": [], "distance": None, "message": "Start or destination is blocked."}
    if start not in graph or goal not in graph:
        return {"path": [], "distance": None, "message": "Unknown start or destination."}
    q=[(0.0,start)]; dist={start:0.0}; prev={start:None}
    while q:
        _,u=heapq.heappop(q)
        if u==goal: break
        for v,w in graph[u]:
            if v in blocked_nodes or frozenset((u,v)) in blocked_edges: continue
            nd=dist[u]+w
            if nd < dist.get(v,float("inf")):
                dist[v]=nd; prev[v]=u
                x,y=points[v]; gx,gy=points[goal]
                h=((gx-x)**2+(gy-y)**2)**0.5
                heapq.heappush(q,(nd+h,v))
    if goal not in dist:
        return {"path": [], "distance": None, "message": "No route is available."}
    path=[]; cur=goal
    while cur is not None: path.append(cur); cur=prev[cur]
    path.reverse()
    return {"path":path,"distance":round(dist[goal],2),"message":"Route calculated."}
