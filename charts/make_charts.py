"""Draws the README charts from aggregate tables (counts only, no personal data).

The CSVs in charts/data/ are the results of GROUP BY queries in 03_data_validation
and 04_analysis. Run from the repository root:   python charts/make_charts.py
"""
import matplotlib.pyplot as plt
import matplotlib.ticker as mtick
import pandas as pd
from matplotlib.patches import FancyBboxPatch

from chart_style import BLUE, GREY, GREY_LIGHT, INK, INK2, new_figure, tidy, save

D, IMG = "charts/data", "images"


def data_model(path):
    """The four tables, their keys and how they link."""
    fig = plt.figure(figsize=(12, 6.2))
    fig.text(0.07, 0.945, "Four tables, one key: every table links to alumni on roll_number",
             fontsize=15, fontweight="bold", color=INK)
    fig.text(0.07, 0.9, "Data model on Azure SQL Database. PK = primary key, FK = foreign key",
             fontsize=11, color=INK2)
    ax = fig.add_axes([0, 0.06, 1, 0.8]); ax.set_xlim(0, 100); ax.set_ylim(0, 62); ax.axis("off")

    def table(x, y, w, name, rows, cols, main=False):
        h = 9 + 4.2 * len(cols)
        ax.add_patch(FancyBboxPatch((x, y - h), w, h, boxstyle="round,pad=0,rounding_size=1.2",
                                    fc=BLUE if main else "white", ec=BLUE if main else GREY, lw=1.6,
                                    alpha=0.12 if main else 1))
        ax.add_patch(FancyBboxPatch((x, y - h), w, h, boxstyle="round,pad=0,rounding_size=1.2",
                                    fc="none", ec=BLUE if main else GREY, lw=1.6))
        ax.text(x + 2, y - 4, name, fontsize=13, fontweight="bold", color=INK, va="center")
        ax.text(x + w - 2, y - 4, rows, fontsize=10, color=INK2, va="center", ha="right")
        ax.plot([x, x + w], [y - 7.5, y - 7.5], color=GREY_LIGHT, lw=1)
        for i, col in enumerate(cols):
            key = col.startswith(("PK", "FK"))
            ax.text(x + 2, y - 11 - 4.2 * i, col, fontsize=10.5, va="center",
                    color=INK if key else INK2, fontweight="bold" if key else "normal")
        return (x, y, w, h)

    a = table(38, 61, 24, "alumni", "22,794 rows",
              ["PK  roll_number", "full_name", "gender", "deceased"], main=True)
    e = table(5, 34, 26, "education", "22,794 rows",
              ["PK/FK  roll_number", "program, school", "graduation_year"])
    c = table(37, 26, 26, "contact", "22,794 rows",
              ["PK/FK  roll_number", "emails, mobile", "city, country, residence"])
    m = table(69, 34, 26, "employment", "20,196 rows",
              ["FK  roll_number", "designation, company", "industry, job_location"])

    def link(x1, y1, x2, y2, label, dx=0, ha="center"):
        ax.plot([x1, x2], [y1, y2], color=GREY, lw=1.4)
        ax.text((x1 + x2) / 2 + dx, (y1 + y2) / 2, label, fontsize=9.5, color=INK2, ha=ha, va="center")

    link(38, 48, 31, 34, "exactly 1  ", ha="right")
    link(50, 35.2, 50, 26, "  exactly 1", ha="left")
    link(62, 48, 69, 34, "  0 or 1: use LEFT JOIN", ha="left")
    fig.text(0.07, 0.02, "No personal data is stored in this repository; it holds SQL code, structure and aggregate counts only.",
             fontsize=9, color=INK2)
    fig.savefig(path, dpi=130); plt.close(fig); print("saved", path)


def graduates_by_year(path):
    d = pd.read_csv(f"{D}/alumni_by_graduation_year.csv")
    d["change"] = d.alumni.diff()
    fig, ax = new_figure("Graduating classes reached about 1,400–1,500 a year; 2020 dipped and 2021 jumped",
                         "Alumni by graduation year, 1988–2026")
    tidy(ax)
    hi = d.graduation_year.isin([2020, 2021])
    ax.bar(d.graduation_year, d.alumni, color=[BLUE if h else GREY_LIGHT for h in hi], width=0.75)
    for r in d[hi].itertuples():
        ax.text(r.graduation_year, r.alumni + 25, f"{r.change:+.0f}".replace("-", "\u2212"), ha="center", fontsize=10,
                fontweight="bold", color=INK)
    ax.text(2020.5, 1650, "Delayed graduations\nduring Covid", ha="center", fontsize=9.5, color=INK2)
    ax.set_ylim(0, 1800); ax.set_xlim(1987, 2027)
    save(fig, path, "Labels show the change from the previous year.")


def job_data_by_program(path):
    d = pd.read_csv(f"{D}/job_data_by_program.csv")
    d["pct"] = d.no_job_record / d.alumni * 100
    d = d.sort_values("pct")
    fig, ax = new_figure("Job data is most complete for MBA alumni and least complete for MSc and PhD",
                         "% of alumni with no job record, by program (number of alumni in brackets)")
    tidy(ax, grid_axis="x")
    labels = [f"{p} ({n:,})" for p, n in zip(d.program, d.alumni)]
    colors = [BLUE if p in ("MSc", "PhD") else GREY_LIGHT for p in d.program]
    ax.barh(labels, d.pct, color=colors, height=0.68)
    for y, v in enumerate(d.pct):
        ax.text(v + 0.4, y, f"{v:.1f}%", va="center", fontsize=10, color=INK2)
    ax.xaxis.set_major_formatter(mtick.PercentFormatter(decimals=0)); ax.set_xlim(0, 30)
    fig.subplots_adjust(left=0.17)
    save(fig, path, "Blue = the two programs to target in the next data-update campaign.")


def abroad_by_school(path):
    d = pd.read_csv(f"{D}/alumni_abroad_by_school.csv")
    d["pct"] = d.abroad / d.alumni * 100
    d = d.sort_values("pct")
    top = d.iloc[-1]
    fig, ax = new_figure(f"{top.school} has the highest share of alumni living abroad: {top.pct:.0f}%",
                         "% of each school's alumni living outside Pakistan (number abroad in brackets)")
    tidy(ax, grid_axis="x")
    ax.barh(d.school, d.pct, color=[BLUE if s == top.school else GREY_LIGHT for s in d.school], height=0.6)
    for y, r in enumerate(d.itertuples()):
        ax.text(r.pct + 0.6, y, f"{r.pct:.0f}%  ({r.abroad:,})", va="center", fontsize=10, color=INK2)
    ax.xaxis.set_major_formatter(mtick.PercentFormatter(decimals=0)); ax.set_xlim(0, 55)
    save(fig, path)


if __name__ == "__main__":
    data_model(f"{IMG}/00_data_model.png")
    graduates_by_year(f"{IMG}/01_graduates_by_year.png")
    job_data_by_program(f"{IMG}/02_job_data_by_program.png")
    abroad_by_school(f"{IMG}/03_abroad_by_school.png")
