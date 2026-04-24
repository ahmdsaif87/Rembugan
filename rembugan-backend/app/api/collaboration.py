from fastapi import APIRouter, Depends, HTTPException
from prisma import Prisma

from app.core.security import verify_token
from app.core.database import get_db
from app.schemas.collaboration import ApplyInput, ApplicationRespondInput

router = APIRouter(prefix="/collaboration", tags=["3. Collaboration & Apply"])


@router.post("/apply", summary="Lamar/Request Join ke Proyek")
async def apply_to_project(
    data: ApplyInput,
    user_token: dict = Depends(verify_token),
    db: Prisma = Depends(get_db),
):
    """
    Kirim lamaran ke sebuah proyek. Validasi:
    - Proyek harus ada dan statusnya 'open'
    - Tidak boleh melamar proyek sendiri
    - Tidak boleh melamar dua kali ke proyek yang sama
    """
    applicant_uid = user_token.get("uid")

    # Cek proyek ada dan masih open
    project = await db.project.find_unique(where={"id": data.project_id})
    if not project:
        raise HTTPException(status_code=404, detail="Proyek tidak ditemukan.")
    if project.status != "open":
        raise HTTPException(status_code=400, detail="Proyek ini sudah tidak menerima lamaran.")
    if project.owner_id == applicant_uid:
        raise HTTPException(status_code=400, detail="Tidak bisa melamar ke proyek sendiri.")

    # Cek duplikasi lamaran
    existing = await db.projectapplication.find_first(
        where={
            "project_id": data.project_id,
            "applicant_id": applicant_uid,
        }
    )
    if existing:
        raise HTTPException(status_code=400, detail="Kamu sudah melamar ke proyek ini.")

    # Simpan lamaran
    application = await db.projectapplication.create(
        data={
            "project_id": data.project_id,
            "applicant_id": applicant_uid,
        },
        include={"project": True, "applicant": True},
    )

    return {
        "status": "success",
        "message": "Lamaran berhasil dikirim! Menunggu persetujuan owner.",
        "data": {
            "id": application.id,
            "project_title": application.project.title if application.project else None,
            "applicant_name": application.applicant.full_name if application.applicant else None,
            "status": application.status,
            "applied_at": application.applied_at.isoformat(),
        },
    }


@router.get("/applications/{project_id}", summary="Lihat Semua Lamaran di Proyek")
async def get_project_applications(
    project_id: int,
    user_token: dict = Depends(verify_token),
    db: Prisma = Depends(get_db),
):
    """Ambil daftar semua lamaran untuk proyek tertentu. Hanya owner yang bisa melihat."""
    user_id = user_token.get("uid")

    # Validasi ownership
    project = await db.project.find_unique(where={"id": project_id})
    if not project:
        raise HTTPException(status_code=404, detail="Proyek tidak ditemukan.")
    if project.owner_id != user_id:
        raise HTTPException(status_code=403, detail="Hanya owner proyek yang bisa melihat lamaran.")

    applications = await db.projectapplication.find_many(
        where={"project_id": project_id},
        include={"applicant": {"include": {"skills": {"include": {"skill": True}}}}},
        order={"applied_at": "desc"},
    )

    result = []
    for app in applications:
        skills = []
        if app.applicant and app.applicant.skills:
            skills = [us.skill.name for us in app.applicant.skills]

        result.append({
            "id": app.id,
            "applicant_id": app.applicant_id,
            "applicant_name": app.applicant.full_name if app.applicant else None,
            "applicant_skills": skills,
            "status": app.status,
            "applied_at": app.applied_at.isoformat(),
        })

    return {"status": "success", "data": result}


@router.put("/applications/{application_id}/respond", summary="Accept/Reject Lamaran")
async def respond_to_application(
    application_id: int,
    data: ApplicationRespondInput,
    user_token: dict = Depends(verify_token),
    db: Prisma = Depends(get_db),
):
    """
    Owner proyek menerima atau menolak lamaran.
    Jika accepted → pelamar otomatis menjadi ProjectMember.
    """
    user_id = user_token.get("uid")

    # Ambil data lamaran
    application = await db.projectapplication.find_unique(
        where={"id": application_id},
        include={"project": True},
    )
    if not application:
        raise HTTPException(status_code=404, detail="Lamaran tidak ditemukan.")

    # Validasi ownership
    if application.project.owner_id != user_id:
        raise HTTPException(status_code=403, detail="Hanya owner proyek yang bisa merespons lamaran.")

    if application.status != "pending":
        raise HTTPException(status_code=400, detail=f"Lamaran sudah di-{application.status}.")

    # Update status lamaran
    updated = await db.projectapplication.update(
        where={"id": application_id},
        data={"status": data.status},
    )

    # Jika accepted, tambahkan sebagai member
    if data.status == "accepted":
        await db.projectmember.create(
            data={
                "project_id": application.project_id,
                "user_id": application.applicant_id,
                "role": data.role,
            }
        )

    return {
        "status": "success",
        "message": f"Lamaran berhasil di-{data.status}.",
        "data": {
            "application_id": updated.id,
            "new_status": updated.status,
        },
    }