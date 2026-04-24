# 🚀 Start Your Local Voice AI NOW

## Quick Start (3 Commands)

### 1. Make sure Docker Desktop is running

Check by running:
```powershell
docker ps
```

If you see an error, start Docker Desktop and wait for it to initialize.

### 2. Choose your method:

#### Method A: Simple Script (Recommended)
```powershell
./start-simple.ps1
```
Then choose 1 for CPU or 2 for GPU.

#### Method B: Direct Command (CPU Mode)
```powershell
docker compose -f docker-compose.yml up --build
```

#### Method C: Direct Command (GPU Mode)
```powershell
docker compose -f docker-compose.yml -f docker-compose.gpu.yml up --build
```

### 3. Wait and Open Browser

- **First run:** 10-30 minutes (downloading models)
- **Subsequent runs:** 2-5 minutes

Once you see "Ready on http://0.0.0.0:3000", open:
**http://localhost:3000**

## That's It!

You now have a local voice AI running on your machine.

---

## Stop the Application

Press `Ctrl+C` in the terminal, then run:
```powershell
docker compose down
```

## Need Help?

- **Full guide:** [START_HERE.md](START_HERE.md)
- **Troubleshooting:** [SETUP_GUIDE.md](SETUP_GUIDE.md)
- **Commands:** [QUICK_REFERENCE.md](QUICK_REFERENCE.md)
