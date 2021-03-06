##
# Testing glm with strong rules on data with added synthetic noise.
##


setwd(normalizePath(dirname(R.utils::commandArgs(asValues=TRUE)$"f")))
source('../findNSourceUtils.R')


test <- function(conn) {
    print("Reading in original prostate data.")
        prostate.hex = h2o.uploadFile(conn, locate("smalldata/prostate/prostate.csv.zip"), key="prostate.hex", header=TRUE)
    print("Head of original prostate data: ")
        head(prostate.hex)
    print("Dimension of original prostate data: ")
        dim(prostate.hex)

    print("Reading in synthetic columns.")
        BIN <- h2o.uploadFile(conn, locate("smalldata/prostate/prostate.bin.csv.zip"), key="BIN", header=FALSE)
        FLOAT <- h2o.uploadFile(conn, locate("smalldata/prostate/prostate.float.csv.zip"), key="FLOAT", header=FALSE)
        INT <- h2o.uploadFile(conn, locate("smalldata/prostate/prostate.int.csv.zip"), key="INT", header=FALSE)
    print("Dimension of synthetic data: ")
        print(dim(BIN))
        print(dim(FLOAT))
        print(dim(INT))

    print("Bind synthetic columns to original data.")
        prostate.data <- h2o.assign(cbind(prostate.hex, BIN, FLOAT, INT),"prostate.data")
    print("Head of full dataset: ")
        head(prostate.data) 

    print("Run test/train split at 20/80.")
        prostate.data$split <- ifelse(h2o.runif(prostate.data)>0.8, yes=1, no=0)
        prostate.train <- h2o.assign(prostate.data[prostate.data$split == 0, c(1:12)], "prostate.train")
        prostate.test <- h2o.assign(prostate.data[prostate.data$split == 1, c(1:12)], "prostate.test")
    print("Dimension of train and test sets: ")
        print(dim(prostate.train))
        print(dim(prostate.test))

    print("Run modeling with with and without synthetic data.")
        prostate.def.model <- h2o.glm(x=c("ID","CAPSULE","AGE","RACE","DPROS","DCAPS","PSA","VOL"), y=c("GLEASON"), prostate.train, family="gaussian", lambda_search=FALSE, alpha=1, use_all_factor_levels=1, nfolds=0)
        prostate.bin.model <- h2o.glm(x=c("ID","CAPSULE","AGE","RACE","DPROS","DCAPS","PSA","VOL","BIN"), y=c("GLEASON"), prostate.train, family="gaussian", lambda_search=FALSE, alpha=1, use_all_factor_levels=1, nfolds=0)
        prostate.float.model <- h2o.glm(x=c("ID","CAPSULE","AGE","RACE","DPROS","DCAPS","PSA","VOL","FLOAT"), y=c("GLEASON"), prostate.train, family="gaussian", lambda_search=FALSE, alpha=1, use_all_factor_levels=1, nfolds=0)
        prostate.int.model <- h2o.glm(x=c("ID","CAPSULE","AGE","RACE","DPROS","DCAPS","PSA","VOL","INT"), y=c("GLEASON"), prostate.train, family="gaussian", lambda_search=FALSE, alpha=1, use_all_factor_levels=1, nfolds=0)
        prostate.all.model <- h2o.glm(x=c("ID","CAPSULE","AGE","RACE","DPROS","DCAPS","PSA","VOL","BIN","FLOAT","INT"), y=c("GLEASON"), prostate.train, family="gaussian", lambda_search=FALSE, alpha=1, use_all_factor_levels=1, nfolds=0)

    print("Use models to predict on test set.")
        prostate.def.predict <- h2o.predict(prostate.def.model,prostate.train)
        prostate.bin.predict <- h2o.predict(prostate.bin.model,prostate.train)
        prostate.float.predict <- h2o.predict(prostate.float.model,prostate.train)
        prostate.int.predict <- h2o.predict(prostate.int.model,prostate.train)
        prostate.all.predict <- h2o.predict(prostate.all.model,prostate.train)

    testEnd()
    }

doTest("Testing glm with strong rules on data with added synthetic noise.", test)