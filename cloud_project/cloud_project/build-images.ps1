# Build Docker images for all services
Write-Host "Building Docker images..."

# Build Patient Management API
Write-Host "Building Patient Management API..."
docker build -t patient-management-api:latest -f PatientManagement.API/Dockerfile .

# Build EHR API
Write-Host "Building EHR API..."
docker build -t ehr-api:latest -f EHR.API/Dockerfile .

# Build Appointment Scheduling API
Write-Host "Building Appointment Scheduling API..."
docker build -t appointment-scheduling-api:latest -f AppointmentScheduling.API/Dockerfile .

Write-Host "All images built successfully!" 