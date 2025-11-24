import argparse
import os
import random
import string
import sys
from typing import Optional

import requests


def random_email() -> str:
  suffix = "".join(random.choices(string.ascii_lowercase + string.digits, k=8))
  return f"test_{suffix}@gmail.com"


def random_phone() -> str:
  digits = "".join(random.choices(string.digits, k=9))
  return f"+375{digits}"


def random_password() -> str:
  return "TestPass1!"


def make_request(method: str, url: str, **kwargs) -> requests.Response:
  print(f"{method.upper()} {url}")
  if "json" in kwargs:
    print("Payload:", kwargs["json"])
  response = requests.request(method, url, timeout=15, **kwargs)
  print("Status:", response.status_code)
  try:
    data = response.json()
    print("Response JSON:", data)
  except ValueError:
    data = response.text
    print("Response text:", data)

  if not response.ok:
    raise SystemExit(f"Request failed: {response.status_code} {response.text}")

  return response


def run_flow(base_url: str, email: str, phone: str, password: str) -> None:
  base_url = base_url.rstrip("/")

  print("\n=== Шаг 1. Проверяем email и телефон ===")
  make_request(
      "get",
      f"{base_url}/auth/check-email",
      params={
          "email": email,
          "phone": phone,
      },
  )

  print("\n=== Шаг 2. Регистрируем пользователя ===")
  make_request(
      "post",
      f"{base_url}/auth/register",
      json={
          "name": "Test",
          "surname": "User",
          "email": email,
          "password": password,
          "phone": phone,
      },
  )

  print("\n=== Шаг 3. Пытаемся войти ===")
  make_request(
      "post",
      f"{base_url}/auth/login",
      json={
          "email": email,
          "password": password,
      },
  )

  print("\n✔ Регистрация и авторизация прошли успешно.")


def parse_args(argv: Optional[list[str]] = None) -> argparse.Namespace:
  default_base = os.getenv("TEST_BASE_URL", "http://127.0.0.1:8000/api/v1")
  parser = argparse.ArgumentParser(
      description="Проверка полного сценария регистрации пользователя через API.",
  )
  parser.add_argument(
      "--base-url",
      default=default_base,
      help=f"Базовый URL API (по умолчанию {default_base!r}).",
  )
  parser.add_argument("--email", help="Email для регистрации. Если не указан — сгенерируется.")
  parser.add_argument("--phone", help="Телефон в формате +375xxxxxxxxx. Если не указан — сгенерируется.")
  parser.add_argument(
      "--password",
      help="Пароль для регистрации. Если не указан — используется безопасный дефолт.",
  )
  return parser.parse_args(argv)


def main() -> None:
  args = parse_args()
  email = args.email or random_email()
  phone = args.phone or random_phone()
  password = args.password or random_password()

  print("=== Параметры теста ===")
  print("API base URL :", args.base_url)
  print("Email        :", email)
  print("Phone        :", phone)
  print("Password     :", password)

  run_flow(args.base_url, email, phone, password)


if __name__ == "__main__":
  try:
    main()
  except KeyboardInterrupt:
    print("\nОперация прервана пользователем.", file=sys.stderr)

