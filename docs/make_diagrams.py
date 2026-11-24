"""Draws the two diagrams used in the README (no data is read; structure only).

    python docs/make_diagrams.py
"""
import matplotlib.pyplot as plt
from matplotlib.patches import FancyBboxPatch

INK, INK2, LINE, SURFACE = "#0b0b0b", "#52514e", "#9a9893", "#fcfcfb"
BLUE, AQUA, VIOLET, ORANGE = "#2a78d6", "#1baf7a", "#6250d6", "#eb6834"
plt.rcParams.update({"font.family": "DejaVu Sans", "figure.facecolor": SURFACE})


def rbox(ax, x, y, w, h, fc, ec, lw=1.4, r=1.4, z=2):
    ax.add_patch(FancyBboxPatch((x, y), w, h, boxstyle=f"round,pad=0,rounding_size={r}",
                                fc=fc, ec=ec, lw=lw, zorder=z))


def badge(ax, x, y, text, color, ha="left"):
    ax.text(x, y, text, fontsize=8.5, fontweight="bold", color="white", va="center", ha=ha, zorder=6,
            bbox=dict(boxstyle="round,pad=0.25,rounding_size=0.6", fc=color, ec="none"))


def table(ax, x, y_top, w, name, color, rows, question, columns):
    """A table card: coloured header, the question it answers, its columns."""
    row_h, head_h = 3.3, 7.6
    h = head_h + 3.6 + row_h * len(columns)
    rbox(ax, x, y_top - h, w, h, "white", color, lw=1.8)
    rbox(ax, x, y_top - head_h, w, head_h, color, color, lw=1.8)
    ax.add_patch(plt.Rectangle((x + 0.05, y_top - head_h), w - 0.1, 1.6, fc=color, ec="none", zorder=3))
    ax.text(x + 2, y_top - 3.0, name, fontsize=14, fontweight="bold", color="white", va="center", zorder=4)
    ax.text(x + w - 2, y_top - 3.0, rows, fontsize=9.5, color="white", va="center", ha="right", zorder=4)
    ax.text(x + 2, y_top - 6.0, question, fontsize=9.5, color="white", va="center", style="italic", zorder=4)
    yy = y_top - head_h - 3.6
    for col in columns:
        if col.startswith(("PK ", "FK ", "PK/FK ")):
            tag, name_ = col.split(" ", 1)
            ax.text(x + 2, yy, name_, fontsize=10.5, fontweight="bold", color=INK, va="center", zorder=6)
            badge(ax, x + w - 2, yy, tag, color if tag != "FK" else INK2, ha="right")
        else:
            ax.text(x + 2, yy, col, fontsize=10.5, color=INK2, va="center", zorder=6)
        yy -= row_h
    return y_top - h


def pill(ax, x, y, text):
    ax.text(x, y, text, fontsize=9.5, fontweight="bold", color=INK, ha="center", va="center", zorder=7,
            bbox=dict(boxstyle="round,pad=0.35,rounding_size=0.8", fc="white", ec=LINE, lw=1))


def data_model(path):
    fig = plt.figure(figsize=(12, 7.0))
    fig.text(0.05, 0.945, "One person, one roll number: four linked tables answer every request",
             fontsize=16, fontweight="bold", color=INK)
    fig.text(0.05, 0.905, "LUMS alumni database on Azure SQL. Each card shows the question the table answers.",
             fontsize=11, color=INK2)
    ax = fig.add_axes([0.02, 0.07, 0.96, 0.82]); ax.set_xlim(0, 100); ax.set_ylim(7, 78); ax.axis("off")

    # links first, so cards sit on top
    for (x1, y1, x2, y2) in [(50, 56, 17, 40), (50, 56, 50, 33), (50, 56, 83, 40)]:
        ax.plot([x1, x2], [y1, y2], color=LINE, lw=2, zorder=1, solid_capstyle="round")
    pill(ax, 30.5, 48.5, "1 : 1")
    pill(ax, 50, 41.5, "1 : 1")
    pill(ax, 69.5, 48.5, "1 : 0 or 1  → LEFT JOIN")

    table(ax, 36, 77, 28, "alumni", BLUE, "22,794 rows", "Who is this person?",
          ["PK roll_number", "full_name, gender", "nationality", "deceased  (always excluded)"])
    table(ax, 2, 40, 30, "education", AQUA, "22,794 rows", "What and when did they study?",
          ["PK/FK roll_number", "program, major, school", "graduation_year", "further study (LinkedIn)"])
    table(ax, 35, 33, 30, "contact", VIOLET, "22,794 rows", "Where are they, how do we reach them?",
          ["PK/FK roll_number", "email, mobile, LinkedIn", "city, country", "residence: Pakistan / Abroad"])
    table(ax, 68, 40, 30, "employment", ORANGE, "20,196 rows", "Where do they work now?",
          ["PK employment_id", "FK roll_number", "designation, company", "industry, job_location"])

    fig.text(0.05, 0.03, "PK = primary key (unique ID)   ·   FK = foreign key (link to alumni)   ·   "
             "No personal data is stored in this repository.", fontsize=9.5, color=INK2)
    fig.savefig(path, dpi=130); plt.close(fig); print("saved", path)


def workflow(path):
    steps = [
        ("Prepare data", "merge 4 sources,\nclean, standardise,\nfill gaps"),
        ("Build database", "4 tables, keys,\nviews, procedure"),
        ("Validate", "row counts, links,\nquality checks"),
        ("Analyse", "KPIs, trends,\nsegmentation"),
        ("Answer requests", "lists and reports\nfor colleagues"),
    ]
    colors = [INK2, BLUE, BLUE, BLUE, AQUA]
    fig = plt.figure(figsize=(12, 3.4))
    fig.text(0.05, 0.9, "From raw files to answered requests in five steps",
             fontsize=16, fontweight="bold", color=INK)
    fig.text(0.05, 0.81, "Each step has its own folder in this repository",
             fontsize=11, color=INK2)
    ax = fig.add_axes([0.02, 0.04, 0.96, 0.72]); ax.set_xlim(0, 100); ax.set_ylim(4, 28); ax.axis("off")
    w, gap, x0 = 17.0, 2.9, 2.5
    for i, ((verb, detail), c) in enumerate(zip(steps, colors)):
        x = x0 + i * (w + gap)
        rbox(ax, x, 6, w, 20, "white", c, lw=1.8)
        ax.scatter([x + 2.9], [22.2], s=330, color=c, zorder=4)
        ax.text(x + 2.9, 22.2, str(i + 1), fontsize=10.5, fontweight="bold", color="white", ha="center",
                va="center", zorder=5)
        ax.text(x + 1.6, 17.6, verb, fontsize=12, fontweight="bold", color=INK, va="center", zorder=5)
        ax.text(x + 1.6, 14.6, detail, fontsize=9.8, color=INK2, va="top", linespacing=1.45, zorder=5)
        if i < len(steps) - 1:
            ax.annotate("", (x + w + gap - 0.2, 16), (x + w + 0.2, 16),
                        arrowprops=dict(arrowstyle="-|>", color=LINE, lw=1.6, mutation_scale=14))
    fig.savefig(path, dpi=130); plt.close(fig); print("saved", path)


if __name__ == "__main__":
    data_model("docs/data_model.png")
