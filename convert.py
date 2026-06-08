import csv
from pathlib import Path


ROOT_DIR = Path(__file__).parent
IMPORT_DIR = ROOT_DIR / "import"

IMPORT_DIR.mkdir(exist_ok=True)


def convert_movies():
    with open(ROOT_DIR / "movies.dat", encoding="latin-1") as f_in, \
            open(IMPORT_DIR / "movies.csv", "w", newline="", encoding="utf-8") as f_out:
        
        writer = csv.writer(f_out)
        writer.writerow(['movieId', 'title', 'genres'])
        
        for line in f_in:
            parts = line.strip().split("::")
            writer.writerow(parts)


def convert_ratings():
    with open(ROOT_DIR / "ratings.dat", encoding="latin-1") as f_in, \
            open(IMPORT_DIR / "ratings.csv", "w", newline="", encoding="utf-8") as f_out:
        writer = csv.writer(f_out)
        writer.writerow(['userId', 'movieId', 'rating', 'timestamp'])

        for line in f_in:
            parts = line.strip().split("::")
            writer.writerow(parts)


def convert_users():
    with open(ROOT_DIR / "users.dat", encoding="latin-1") as f_in, \
            open(IMPORT_DIR / "users.csv", "w", newline="", encoding="utf-8") as f_out:
        writer = csv.writer(f_out)
        writer.writerow(["userId", "gender", "age", "occupation"])

        for line in f_in:
            parts = line.strip().split("::")
            writer.writerow(parts[:4])

if __name__ ==  "__main__":
    convert_movies()
    convert_ratings()
    convert_users()

    print("Успішно створені в імпорт файлі")
