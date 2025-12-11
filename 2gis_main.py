import time
from playwright.sync_api import sync_playwright, Page
from translate import Translator
from typing import List


class TwoGisMapParse:
    def __init__(self, keyword: str, sity: str):
        self.keyword = keyword  #  Ищем по ключевому слову
        self.sity = sity  # Ищем в определённом городе
        self.list_organizations_name = []  # Список для организаций

    def extract_organization_links_current_page(self, page: Page) -> List[str]:
        """Извлекаем ссылки на организации, находящиеся на странице"""
        print("Собираем ссылки на организации с текущей страницы...")

        links = []
        link_selector = 'a[href*="/firm/"]'

        found_links = page.query_selector_all(link_selector)  # Ищем только видимые карточки организаций(firm)
        for link in found_links:
            if not link.is_visible():  # Проверяем, видим ли элемент
                continue
            href = (link.get_attribute("href") or "")  # Находим элемент на стр., где есть /firm/
            # На всякий случай делаю ещё проверку; Ещё проверяю город, чтоб не искало в регионах
            if (href and "/firm/" in href and self.eng_sity() in href):
                href = rf"https://2gis.ru{href}"
                links.append(href)
        return links

    def eng_sity(self):
        """Переводим город на английский для удобства"""
        return self.translate_text(self.sity).lower()

    def parse(self):
        """Парсинг сайта"""
        with sync_playwright() as playwright:
            browser = playwright.chromium.launch(headless=False)  # headless=False - без графического итерфейса
            self.context = browser.new_context()  # По типу вкладок инкогнито
            self.page = self.context.new_page()  # Новая страница, создается в контексте
            self.page.goto(f"https://2gis.ru/{self.eng_sity()}")  #  Переходим по адресу с переведенным городом
            # Ищем поле поиска, пишем туда keyword и печатаем каждую букву с промежутком времени 0.4 с
            self.page.get_by_placeholder("Поиск в 2ГИС").type(text=self.keyword, delay=0.4)
            self.page.keyboard.press("Enter")  # Нажимаем Enter
            time.sleep(3)  # Задержка для загрузки страницы
            print(self.extract_organization_links_current_page(self.page))  # Вывод ссылок на организации
            self.page.click('[style="transform: rotate(-90deg);"]')  # Кликаем на кнопку перехода на след. страницу
            time.sleep(120)

    def translate_text(self, text, from_lang="ru", to_lang="en"):
        # Создаем объект Translator, указывая исходный язык и язык перевода
        translator = Translator(from_lang=from_lang, to_lang=to_lang)
        try:
            # Пытаемся перевести текст
            translated_text = translator.translate(text)
            return translated_text  # Возвращаем переведенный текст
        except Exception as e:
            # Если возникает ошибка, возвращаем сообщение об ошибке
            return f"Error: {e}"


if __name__ == "__main__":
    TwoGisMapParse("Мойка", "Ростов на Дону").parse()
