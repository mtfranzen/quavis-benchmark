import numpy as np
import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt
plt.style.use('ggplot')

OUT_PATH="output/plots/"

if __name__ == '__main__':
    df = pd.read_csv("output/output.csv", delimiter=';')
    df["ERROR"] = abs((df["EXPECTED_RESULT"] - df["ACTUAL_RESULT"])/df["EXPECTED_RESULT"])

    df_spherical = df[df["MAPPING"] == "SPHERICAL"]
    df_cube = df[df["MAPPING"] == "CUBE"]

    for obj in np.unique(df_spherical["OBJ"].values):
        df_obj = df_spherical[df_spherical["OBJ"] == obj]

        plt.clf()
        ax = sns.lmplot(x="ALPHA", y="GRAPHICS_FPS", hue="FUNCTION", data=df_obj)
        ax.title = (str.format(r"{0} - $\alpha_\max$ vs. GFPS", obj))
        plt.savefig(OUT_PATH + str.format(r"{0}_alpha_v_GFPS.png", obj))

        plt.clf()
        ax = sns.lmplot(x="ALPHA", y="COMPUTE_FPS", hue="FUNCTION", data=df_obj)
        ax.title = (str.format(r"{0} - $\alpha_\max$ vs. CFPS", obj))
        plt.savefig(OUT_PATH + str.format(r"{0}_alpha_v_CFPS.png", obj))

        plt.clf()
        ax = sns.lmplot(x="ALPHA", y="ERROR", hue="FUNCTION", data=df_obj)
        ax.title = (str.format(r"{0} - $\alpha_\max$ vs. error", obj))
        plt.savefig(OUT_PATH + str.format(r"{0}_alpha_v_ERR.png", obj))

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
