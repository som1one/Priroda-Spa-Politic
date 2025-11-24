import httpx
import asyncio

BASE_URL = "https://api.yclients.com/api/v1"
COMPANY_ID = 235564
PARTNER_TOKEN = "w2n67wn87jecywk2seh4"
USER_TOKEN = "b305a97a405b29e18fdb9e1eca84dc09"

HEADERS = {
    "Content-Type": "application/json",
    "Accept": "application/vnd.api.v2+json",     # 🔥 ОБЯЗАТЕЛЬНО!
    "Authorization": f"Bearer {PARTNER_TOKEN}",
    "User-Token": USER_TOKEN,
}


async def get_services():
    url = f"{BASE_URL}/company/{COMPANY_ID}/services"
    async with httpx.AsyncClient() as client:
        r = await client.get(url, headers=HEADERS)
        print("STATUS:", r.status_code)
        print(r.text)
        r.raise_for_status()
        return r.json()


async def get_staff():
    url = f"{BASE_URL}/company/{COMPANY_ID}/staff"
    async with httpx.AsyncClient() as client:
        r = await client.get(url, headers=HEADERS)
        print("STATUS:", r.status_code)
        print(r.text)
        r.raise_for_status()
        return r.json()


async def main():
    print("==============================")
    print("🔐 ТЕСТ YCLIENTS API (ХАРДКОД)")
    print("==============================")

    print("\n1) Получаем услуги...")
    services = await get_services()

    print("\n2) Получаем мастеров...")
    staff = await get_staff()

    print("\n\nГотово!")
    print("Услуг:", len(services.get("data", [])))
    print("Мастеров:", len(staff.get("data", [])))


if __name__ == "__main__":
    asyncio.run(main())
