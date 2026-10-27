"""A* shortest-path search for the supplied hospital walkable graph."""
import heapq
from graph_data import build_graph, all_positions

def astar(start, goal):
    graph = build_graph()
    points = all_positions()
    if start not in graph or goal not in graph:
        raise ValueError("Start or destination is not a known map node.")
    queue = [(0.0, start)]
    came_from = {start: None}
    g_score = {start: 0.0}
    while queue:
        _, current = heapq.heappop(queue)
        if current == goal:
            path = []
            while current is not None:
                path.append(current)
                current = came_from[current]
            path.reverse()
            return {"path": path, "distance": round(g_score[goal], 2)}
        for neighbor, edge_cost in graph[current]:
            tentative = g_score[current] + edge_cost
            if tentative < g_score.get(neighbor, float("inf")):
                came_from[neighbor] = current
                g_score[neighbor] = tentative
                x1,y1 = points[neighbor]; x2,y2 = points[goal]
                heuristic = ((x2-x1)**2 + (y2-y1)**2)**0.5
                heapq.heappush(queue, (tentative + heuristic, neighbor))
    return {"path": [], "distance": None}
