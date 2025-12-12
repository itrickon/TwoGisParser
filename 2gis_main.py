import time, re
from playwright.sync_api import sync_playwright, Page
from translate import Translator
from typing import List


class TwoGisMapParse:
    def __init__(self, keyword: str, sity: str, max_num_firm: int):
        self.keyword = keyword  #  Ищем по ключевому слову
        self.sity = sity  # Ищем в определённом городе
        self.max_num_firm = max_num_firm  # Максимальное количество фирм

    def eng_sity(self):
        """Переводим город на английский для удобства"""
        return self.translate_text(self.sity).lower()

    def __get_links(self) -> List[str]:
        """Извлекаем ссылки на организации, находящиеся на странице"""
        print("Собираем ссылки на организации с текущей страницы...")

        links = []
        link_selector = 'a[href*="/firm/"]'
        
        found_links = self.page.query_selector_all(link_selector)  # Ищем только видимые карточки организаций(firm)
        for count, link in enumerate(found_links):
            if count > self.max_num_firm:  # Делаем так, чтобы кол-во не превышало желамое кол-во объявлений
                break 
            if not link.is_visible():  # Проверяем, видим ли элемент
                continue
            href = (link.get_attribute("href") or "")  # Находим элемент на стр., где есть /firm/
            # На всякий случай делаю ещё проверку; Ещё проверяю город, чтоб не искало в регионах
            if (href and "/firm/" in href and self.eng_sity() in href):
                href = rf"https://2gis.ru{href}"
                links.append(href)
                self.__get_firm_data(url=href)
        return links

    def __get_firm_data(self, url: str):
        """Берем данные фирмы: название, телефон, сайт"""
        self.page2 = self.context.new_page()  # Создаем новую страницу
        self.page2.goto(url=url)  # Переходим на неё
        
        # Название фирмы
        firm_title = self.page2.title().split(',')[0]  #Отделяем: (Назв.фирмы, ул. ...) 
        print(firm_title)
        
        # Номер телефона
        try:
            # Находим контейнер, затем ссылку внутри него
            phone_container = self.page2.query_selector(':has(button:has-text("Показать телефон")):has(a[href^="tel:"])')
            if phone_container:
                # Теперь ищем телефон внутри этого контейнера
                phone = phone_container.query_selector('a[href^="tel:"]')
                print(phone.get_attribute("href")[4:])  # Вывожу без tel:
            else:
                print("Контейнер с телефоном и кнопкой не найден")
        except Exception as e:
            print(f"Ошибка: {e}")
        
        # Название сайта
        site_elements = self.page2.query_selector_all('a[href^="https://link.2gis.ru/"]')  # Ищем ссылки(сайт)
        if site_elements:  # Если есть хоть одна ссылка
            site_texts = [element.text_content().strip() for element in site_elements]
            try:
                a = list(filter(lambda i: i if ('.ru' in i or '.com' in i or '.net' in i or '.рф' in i) and
                            '@' not in i else '', site_texts))  # Фильтруем, чтоб выводилось нужное 
                print(f"{a[0]}")
            except:
                print(f"Нет ссылки на сайт")
                
        self.page2.close()

# TODO: Сделать запись данных в xlsx

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
            print(self.__get_links())  # Вывод ссылок на организации
            # for i in range(6):
            #     self.page.click('[style="transform: rotate(-90deg);"]')  # Кликаем на кнопку перехода на след. страницу
            time.sleep(4)
            self.__get_links()
            time.sleep(180)

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
    TwoGisMapParse("Музеи", "Саратов", 322).parse()  # Ключевое слово, город, кол-во объявлений
