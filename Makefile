#CXX = g++
#CXX = clang++

ROOT_DIR:=$(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))

PACKAGE = ccc
TEST_PACKAGE = test

LIB := lib
SRC := src
INC := include
LANG := language
GEN := generated
BIN := bin

antlr4_SRC := repos/antlr4

HEADERS:=-I$(INC) -I$(GEN)/$(LANG) -I$(INC)/antlr4-runtime
LIBS:=-L$(LIB)/ -Wl,-rpath=$(ROOT_DIR)/$(LIB) -lantlr4-runtime

CXX:=g++
# CXXFLAGS:= $(HEADERS) -Wall -Wextra -std=c++20 -MMD -O2
CXXFLAGS:= $(HEADERS) -Wall -Wextra -std=c++20 -MMD -g
# LDFLAGS:= -O2
LDFLAGS:= -g

RM:=rm -rfv
MKDIR:=mkdir -pv

CXXFILES := $(GEN)/$(LANG)/CCCLexer.cpp \
			$(GEN)/$(LANG)/CCCParser.cpp \
			$(SRC)/main.cxx
OFILES := $(addsuffix .o, $(addprefix $(BIN)/, $(basename $(notdir $(CXXFILES)))))
DFILES := $(OFILES:%.o=%.d)

#=======================

all: $(LIB)/antlr4-complete.jar $(LIB)/libantlr4-runtime.so gen_lang $(PACKAGE)


$(BIN):
	$(MKDIR) $@

$(GEN):
	$(MKDIR) $@

#=======================

$(LIB)/antlr4-complete.jar:
	git -C $(antlr4_SRC) pull || git clone https://github.com/antlr/antlr4 $(antlr4_SRC)
	@echo "> BUILDING antlr4 executable"
	# java > /dev/null 2>&1
	# if [[ "$?" != "0" ]]; then @echo "java was not found in $$PATH..." && exit -1; fi
	# mvn > /dev/null 2>&1
	# if [[ "$?" != "0" ]]; then @echo "mvn was not found in $$PATH..." && exit -1; fi
	export MAVEN_OPTS="-Xmx1G"; cd $(antlr4_SRC); mvn -DskipTests install
	cp -fv ./repos/antlr4/tool/target/antlr4-4.13.1-SNAPSHOT-complete.jar $(LIB)/antlr4-complete.jar

$(LIB)/libantlr4-runtime.so:
	git -C $(antlr4_SRC) pull || git clone https://github.com/antlr/antlr4 $(antlr4_SRC)
	@echo "> BUILDING antlr4 C++ library"
	mkdir -p $(antlr4_SRC)/runtime/Cpp/build
	cd $(antlr4_SRC)/runtime/Cpp/build; cmake .. -DCMAKE_INSTALL_PREFIX=../../../../.. -DCMAKE_BUILD_TYPE=Release -DWITH_DEMO=False -DCMAKE_CXX_STANDARD=20
	cd $(antlr4_SRC)/runtime/Cpp/build; make -j4
	cd $(antlr4_SRC)/runtime/Cpp/build; make install
	cp -rf lib64/*.a $(LIB)/
	cp -rf lib64/*.so* $(LIB)/
	cp -rf lib64/pkgconfig $(LIB)/
	rm -rf share lib64

#=======================

gen_lang: $(LANG)/CCC.g4 | $(GEN)
	java -jar lib/antlr4-complete.jar -Dlanguage=Cpp $< -o $(GEN)

#=======================

$(PACKAGE): $(OFILES)
	$(CXX) $(LDFLAGS) -o $@ $^ $(LIBS)

-include $(DFILES)

$(BIN)/%.o: $(INC)/%.cxx | $(BIN)
	$(CXX) $(CXXFLAGS) -o $@ -c $<

$(BIN)/%.o: $(SRC)/%.cxx | $(BIN)
	$(CXX) $(CXXFLAGS) -o $@ -c $<

$(BIN)/%.o: $(GEN)/$(LANG)/%.cpp | $(BIN)
	$(CXX) $(CXXFLAGS) -o $@ -c $<

#=======================

clean:
	$(RM) $(OFILES) $(DFILES) $(GEN)/*

mrproper: clean
	$(RM) -r $(PACKAGE) $(TEST_PACKAGE) \
		$(BIN)/* \
		$(LIB)/*.a $(LIB)/*.so*

doc:
	doxygen

debug: mrproper all
	valgrind --log-file=bin/vg_output --track-origins=yes --leak-check=full ./$(PACKAGE)

test: clean all
	./$(TEST_PACKAGE)

print_vars:
	@echo "CXXFILES: "$(CXXFILES)
	@echo "OFILES: "$(OFILES)
	@echo "DFILES: "$(DFILES)

.PHONY: clean mrproper debug all doc test

