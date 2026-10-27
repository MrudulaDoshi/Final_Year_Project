# UWB Hospital Indoor Navigation — Python simulation API

This backend models the provided hospital map and its supplied walkable connections. UWB ranges are simulated in software; this does not connect to physical UWB anchors or tags.

## 1. Create environment and install
Windows PowerShell:
```powershell
cd UWB_Hospital_Navigation_New
py -m venv .venv
.venv\Scripts\Activate.ps1
python -m pip install -r requirements.txt
```

## 2. Run server
```powershell
python app.py
```
The API runs on port 5000. Check `http://127.0.0.1:5000/api/health` in your browser. For Android Emulator, Flutter uses `http://10.0.2.2:5000`.

## Endpoints
- `GET /api/health`
- `GET /api/map`
- `GET /api/rooms`
- `GET /api/route?start=N1&destination=ICU`
- `POST /api/simulate` JSON: `{"node":"N1","noise_std":0.08,"seed":1}`
- `POST /api/track` JSON: `{"tag_id":"PATIENT-001","node":"N1"}`
- `GET /api/track/PATIENT-001`
- Accuracy test: `python uwb_accuracy_test.py`

Distances and room dimensions are map-coordinate units, not metres. The supplied graph is used exactly as listed; no missing connections are silently added.
