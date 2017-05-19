import numpy as np
import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt
plt.style.use('ggplot')
print sns.__version__
OUT_PATH="output/plots/"

if __name__ == '__main__':
    df = pd.read_csv("output/output.csv", delimiter=';')
    df["ERROR"] = abs((df["EXPECTED_RESULT"] - df["ACTUAL_RESULT"])/df["EXPECTED_RESULT"])

    df_spherical = df[df["MAPPING"] == "SPHERICAL"]
    df_cube = df[df["MAPPING"] == "CUBE"]
    df2 = df.fillna(0)

    plt.clf()
    ax = sns.pairplot(df2[["MAPPING", "ALPHA", "GRAPHICS_FPS", "COMPUTE_FPS", "FUNCTION", "ERROR"]], hue="MAPPING", diag_kind="kde", dropna=True)
    ax.title = (r"Pair Plot")
    ax.savefig(OUT_PATH + "all_all.png")

    for obj in np.unique(df["OBJ"].values):
        df_obj = df[df["OBJ"] == obj]
        df_obj2 = df_obj.fillna(0)

        plt.clf()
        ax = sns.pairplot(df_obj2[["MAPPING", "ALPHA", "GRAPHICS_FPS", "COMPUTE_FPS", "FUNCTION", "ERROR"]], hue="MAPPING", diag_kind="kde", dropna=True)
        ax.title = (str.format(r"{0} - Pair Plot", obj))
        ax.savefig(OUT_PATH + str.format(r"{0}_all.png", obj))

    plt.clf()
    ax = sns.boxplot(x="MAPPING", y="GRAPHICS_FPS", hue="FUNCTION", data=df)
    ax.set_title("GFPS - Cube vs. Spherical")
    plt.savefig(OUT_PATH + str.format(r"all_gfps_v_mapping.png", obj))

    plt.clf()
    ax = sns.boxplot(x="MAPPING", y="COMPUTE_FPS", hue="FUNCTION", data=df)
    ax.set_title("CFPS - Cube vs. Spherical")
    plt.savefig(OUT_PATH + str.format(r"all_cfps_v_mapping.png", obj))

    plt.clf()
    ax = sns.boxplot(x="MAPPING", y="ERROR", hue="FUNCTION", data=df)
    ax.set_title("ERROR - Cube vs. Spherical")
    plt.savefig(OUT_PATH + str.format(r"all_error_v_mapping.png", obj))
