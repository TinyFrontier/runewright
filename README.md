# Runewright

Фабрика скиллов и субагентов для LLM-агентов. Один GitHub marketplace — два
рантайма: **Claude Code** и **Codex**. Цель: агенты на
дешёвых моделях работают по маршрутам, спроектированным один раз, — без
галлюцинаций и без раздувания контекста.

## Скиллы

| Скилл | Что делает |
|---|---|
| `skill-brief` | Интервью (1–3 раунда) перед созданием скилла: вытягивает задачу, триггеры, источники, критерии → бриф |
| `skill-generator` | Бриф/запрос → готовый SKILL.md по эталонной схеме из 7 элементов, с самопроверкой |
| `subagent-generator` | Роль → субагент Claude Code (`.md`) и/или Codex (`.toml`): границы, минимальные права, параллельность, формат отчёта |
| `skill-audit` | Повторяемый аудит всех скиллов окружения: дубликаты, раздутость, мёртвые скиллы → план правок |
| `runewright-blueprint` | Справочный канон (7 элементов, анти-паттерны, контракт «живого» скилла) — читается остальными |

Рабочий цикл: `skill-brief` → `skill-generator` → работа скиллом → `skill-audit`
раз в месяц. Каждый созданный скилл — «живой»: пишет лог запусков и учится на нём.

## Установка из GitHub marketplace

### Claude Code

В терминале:

```bash
claude plugin marketplace add TinyFrontier/runewright
claude plugin install runewright@runewright
```

Или те же команды внутри интерактивной сессии:

```text
/plugin marketplace add TinyFrontier/runewright
/plugin install runewright@runewright
```

Скиллы доступны как `/runewright:skill-brief`, `/runewright:skill-generator`
и т.д.; Claude также может выбрать их автоматически по description.

### Codex

```bash
codex plugin marketplace add TinyFrontier/runewright
codex plugin add runewright@runewright
```

После установки начните новую задачу, чтобы Codex загрузил компоненты плагина.
Явный вызов: `$runewright:skill-brief`, `$runewright:skill-generator` и т.д.;
автоматический — по description.

Обе команды marketplace принимают приватный репозиторий, если локальный Git уже
авторизован для него. Для публичной установки достаточно сделать этот репозиторий
public и запушить файлы из текущей ветки.

### Локальная разработка Codex без marketplace

```bash
git clone https://github.com/TinyFrontier/runewright.git
cd runewright
./install-codex.sh
./install-codex.sh --project /path/to/repo
```

Скрипт создаёт симлинки в `~/.agents/skills` или `<repo>/.agents/skills`, поэтому
`git pull` обновляет локальные skills без переустановки плагина. При конфликте с
обычной папкой скрипт останавливается с ошибкой и ничего не перезаписывает.

## Состояние проекта

Всё, что фабрика создаёт и накапливает, живёт в **`.runewright/`** в корне вашего
проекта (нейтрально к платформе):

```
.runewright/
  sources/    # источники истины: INDEX.md + decisions/ + external/
  feedback/   # логи запусков скиллов (петля обратной связи)
  briefs/     # брифы из skill-brief
  audits/     # отчёты skill-audit
```

Каркас `sources/` создаёт `skill-generator` при первом запуске (из
`skills/skill-generator/assets/sources-scaffold/`).

## Архитектурные решения

- **Скилл — маршрут, не учебник.** Знания живут в `.runewright/sources/` (три вида
  правды: выводимая — хранится команда получения; решённая — DEC-файлы с основанием;
  внешняя — указатель с датой проверки). Скилл ссылается на ID из плоского INDEX.md.
- **Один формат skills для двух платформ.** Стандарт Agent Skills: `name` +
  `description` во фронтматтере, всё остальное — тело. Ссылки между скиллами —
  относительные (`../runewright-blueprint/SKILL.md`): работают и в кэше плагина
  Claude Code, и через симлинки в `~/.agents/skills`.
- **Два формата ролей.** `subagent-generator` создаёт Markdown с YAML-frontmatter
  для Claude Code и TOML с `developer_instructions` для Codex; контракт роли и
  формат отчёта остаются одинаковыми.
- **Жёсткие лимиты.** Скилл ≤ 150 строк, агент ≤ 100, description ≤ 500 символов.
  Codex и Claude используют descriptions для выбора skill; короткие формулировки
  экономят контекст и лучше переживают сокращение списка при большом числе skills.
- **Ничего не удаляется автоматически.** `skill-audit` только предлагает план;
  применение — после подтверждения человека.

## Проверка перед релизом

```bash
claude plugin validate . --strict
bash -n install-codex.sh
```

Версию релиза нужно менять одновременно в `.claude-plugin/plugin.json` и
`.codex-plugin/plugin.json`. Текущая версия — `0.2.0`.

## Ограничения

- `install-codex.sh` требует POSIX-шелл и нужен только для прямой установки
  skills; пользователям Windows рекомендуется установка через marketplace.
- Форматы конфигурации субагентов различаются между платформами, поэтому один
  и тот же агент представлен двумя файлами, если пользователь запросил обе версии.
