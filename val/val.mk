SBSA_ROOT:= $(SBSA_PATH)
SBSA_DIR := $(SBSA_ROOT)/val/src/
SMMU_DIR := $(SBSA_ROOT)/val/sys_arch_src/smmu_v3
GIC_V3_DIR := $(SBSA_ROOT)/val/sys_arch_src/gic/v3
GIC_V2_DIR := $(SBSA_ROOT)/val/sys_arch_src/gic/v2
GIC_DIR  := $(SBSA_ROOT)/val/sys_arch_src/gic
GIC_ITS_DIR := $(SBSA_ROOT)/val/sys_arch_src/gic/its

SBSA_A64_DIR := $(SBSA_ROOT)/val/src/AArch64/
SBSA_GIC_DIR := $(SBSA_ROOT)/val/sys_arch_src/gic/AArch64/
SBSA_GIC_V3_DIR := $(SBSA_ROOT)/val/sys_arch_src/gic/v3/AArch64/

CFLAGS    += -I$(SBSA_ROOT)/val/include
CFLAGS    += -I$(SBSA_ROOT)/val/
CFLAGS    += -I$(SBSA_ROOT)/val/sys_arch_src/smmu_v3
CFLAGS    += -I$(SBSA_ROOT)/val/sys_arch_src/gic/
CFLAGS    += -I$(SBSA_ROOT)/val/sys_arch_src/gic/its
CFLAGS    += -I$(SBSA_ROOT)/val/sys_arch_src/gic/v3
CFLAGS    += -I$(SBSA_ROOT)/val/sys_arch_src/gic/v2
ASFLAGS   += -I$(SBSA_ROOT)/val/src/AArch64/

OUT_DIR = $(SBSA_ROOT)/build/
OBJ_DIR := $(SBSA_ROOT)/build/obj
LIB_DIR := $(SBSA_ROOT)/build/lib

CC = $(GCC49_AARCH64_PREFIX)gcc -march=armv8.2-a
AR = $(GCC49_AARCH64_PREFIX)ar

FILES   := $(foreach files,$(SBSA_DIR),$(wildcard $(files)/*.c))
FILES   += $(foreach files,$(SMMU_DIR),$(wildcard $(files)/*.c))
FILES   += $(foreach files,$(GIC_V3_DIR),$(wildcard $(files)/*.c))
FILES   += $(foreach files,$(GIC_DIR),$(wildcard $(files)/*.c))
FILES   += $(foreach files,$(SBSA_A64_DIR),$(wildcard $(files)/*.S))
FILES   += $(foreach files,$(SBSA_GIC_DIR),$(wildcard $(files)/*.S))
FILES   += $(foreach files,$(SBSA_GIC_V3_DIR),$(wildcard $(files)/*.S))
FILES   += $(foreach files,$(GIC_ITS_DIR),$(wildcard $(files)/*.c))
FILE    = `find $(FILES) -type f -exec sh -c 'echo {} $$(basename {})' \; | sort -u --stable -k2,2 | awk '{print $$1}'`
FILE_1  := $(shell echo $(FILE))
XYZ     := $(foreach a,$(FILE_1),$(info $(a)))
PAL_OBJS :=$(addprefix $(OBJ_DIR)/,$(addsuffix .o, $(basename $(notdir $(foreach dirz,$(FILE_1),$(dirz))))))

all:  PAL_LIB

create_dirs:
	rm -rf ${OBJ_DIR}
	rm -rf ${LIB_DIR}
	rm -rf ${OUT_DIR}
	@mkdir ${OUT_DIR}
	@mkdir ${OBJ_DIR}
	@mkdir ${LIB_DIR}

$(OBJ_DIR)/%.o: $(SBSA_A64_DIR)/%.S
	$(CC) $(CFLAGS) $(ASFLAGS) -c -o $@ $< >> $(OUT_DIR)/compile.log 2>&1

$(OBJ_DIR)/%.o: $(SBSA_GIC_DIR)/%.S
	$(CC)  $(CFLAGS) $(ASFLAGS) -c -o $@ $< >> $(OUT_DIR)/compile.log 2>&1

$(OBJ_DIR)/%.o: $(SBSA_GIC_V3_DIR)/%.S
	$(CC) $(CFLAGS) $(ASFLAGS) -c -o $@ $< >> $(OUT_DIR)/compile.log 2>&1

$(OBJ_DIR)/%.o: $(SBSA_DIR)/%.c
	$(CC)  $(CFLAGS) -c -o $@ $< >> $(OUT_DIR)/compile.log 2>&1

$(OBJ_DIR)/%.o: $(SMMU_DIR)/%.c
	$(CC)  $(CFLAGS) -c -o $@ $< >> $(OUT_DIR)/compile.log 2>&1

$(OBJ_DIR)/%.o: $(GIC_V3_DIR)/%.c
	$(CC)  $(CFLAGS) -c -o $@ $< >> $(OUT_DIR)/compile.log 2>&1

$(OBJ_DIR)/%.o: $(GIC_V2_DIR)/%.c
	$(CC)  $(CFLAGS) -c -o $@ $< >> $(OUT_DIR)/compile.log 2>&1

$(OBJ_DIR)/%.o: $(GIC_DIR)/%.c
	$(CC)  $(CFLAGS) -c -o $@ $< >> $(OUT_DIR)/compile.log 2>&1

$(OBJ_DIR)/%.o: $(GIC_ITS_DIR)/%.c
	$(CC)  $(CFLAGS) -c -o $@ $< >> $(OUT_DIR)/compile.log 2>&1

$(OBJ_DIR)/%.o: $(SBSA_DIR)/%.S
	$(CC)   -c -o $@ $< >> $(OUT_DIR)/compile.log 2>&1

$(LIB_DIR)/lib_val.a: $(PAL_OBJS)
	$(AR) $(ARFLAGS) $@ $^ >> $(OUT_DIR)/link.log 2>&1

PAL_LIB: $(LIB_DIR)/lib_val.a

clean:
	rm -rf ${OBJ_DIR}
	rm -rf ${LIB_DIR}
	rm -rf ${OUT_DIR}

.PHONY: all PAL_LIB