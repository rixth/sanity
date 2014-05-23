ARDUINO_INSTALL_DIR = /Applications/Arduino.app/Contents/Resources/Java

TARGET     = bin/blink
BUILD_MCU  = atmega328p
F_CPU      = 16000000L
PORT       = /dev/tty.usbmodem1411
PORT_SPEED = 115200

AVR_DIR         = $(ARDUINO_INSTALL_DIR)/hardware/arduino/avr
ARDUINO_CORE    = $(AVR_DIR)/cores/arduino
ARDUINO_LIBS    = $(AVR_DIR)/libraries
ARDUINO_VARIANT = $(AVR_DIR)/variants/standard
AVR_TOOLS_PATH  = $(ARDUINO_INSTALL_DIR)/hardware/tools/avr/bin

SRCDIR   = src
BUILDDIR = build

DEFS     = -mmcu=$(BUILD_MCU) -DF_CPU=$(F_CPU) -DARDUINO=$(VERSION)
INCS      = -I$(ARDUINO_CORE) -I$(ARDUINO_VARIANT)

OPTS      = -O0 -funsigned-char -funsigned-bitfields -ffunction-sections -fdata-sections -fpack-struct -fshort-enums -ffreestanding
CWARN     = -Wstrict-prototypes -Wall
CXXWARN   = -Wall

CFLAGS   = $(DEFS) $(INCS) $(OPTS) $(CWARN)
CXXFLAGS = $(DEFS) $(INCS) $(OPTS) $(CXXWARN)

CXX = $(AVR_TOOLS_PATH)/avr-g++
CC  = $(AVR_TOOLS_PATH)/avr-gcc
AR  = $(AVR_TOOLS_PATH)/avr-ar

C_SOURCES   = $(shell find $(SRCDIR) -type f -name *.c)
CXX_SOURCES = $(shell find $(SRCDIR) -type f -name *.cpp)

CORE_LIB_SRC =  \
$(ARDUINO_VARIANT)/pins_arduino.h \
$(ARDUINO_CORE)/wiring.c \
$(ARDUINO_CORE)/hooks.c \
$(ARDUINO_CORE)/wiring_analog.c \
$(ARDUINO_CORE)/wiring_digital.c \
$(ARDUINO_CORE)/wiring_pulse.c \
$(ARDUINO_CORE)/wiring_shift.c \
$(ARDUINO_CORE)/WInterrupts.c

CORE_LIB_CXX_SRC = \
$(ARDUINO_CORE)/new.cpp \
$(ARDUINO_CORE)/WString.cpp \
$(ARDUINO_CORE)/HardwareSerial.cpp \
$(ARDUINO_CORE)/HardwareSerial0.cpp \
$(ARDUINO_CORE)/WMath.cpp \
$(ARDUINO_CORE)/Print.cpp \

OBJECTS := $(CORE_LIB_SRC:.c=.o)
OBJECTS += $(CORE_LIB_CXX_SRC:.cpp=.o)
OBJECTS += $(patsubst $(SRCDIR)/%,$(BUILDDIR)/%,$(C_SOURCES:.c=.o))
OBJECTS += $(patsubst $(SRCDIR)/%,$(BUILDDIR)/%,$(CXX_SOURCES:.cpp=.o))

all: $(TARGET).hex upload

$(TARGET).elf: $(OBJECTS)
	@echo " Linking (.elf)..."
	$(CC) $(CFLAGS) -Wl,-gc-sections $^ -o $(TARGET).elf $(LIB) -lm

$(TARGET).eep: $(TARGET).elf
	@echo " Making eeprom file (.epp)..."
	@avr-objcopy -O ihex -j .eeprom --set-section-flags=.eeprom=alloc,load --no-change-warnings --change-section-lma .eeprom=0 $(TARGET).elf $(TARGET).eep

$(TARGET).hex: $(TARGET).eep
	 avr-objcopy -O ihex -R .eeprom $(TARGET).elf $(TARGET).hex

$(BUILDDIR)/%.o: $(SRCDIR)/%.c
	@mkdir -p $(BUILDDIR)
	$(CC) $(CFLAGS) -c -o $@ $<

$(BUILDDIR)/%.o: $(SRCDIR)/%.cpp
	@mkdir -p $(BUILDDIR)
	$(CXX) $(CXXFLAGS) -c -o $@ $<

upload: $(TARGET).hex
	 $(AVR_TOOLS_PATH)/avrdude $(AVRDUDE_FLAGS) -C$(AVR_TOOLS_PATH)/../etc/avrdude.conf -patmega328p -carduino -P$(PORT) -b$(PORT_SPEED) -D -U flash:w:$(TARGET).hex:i

clean:
	@echo " Cleaning...";
	$(RM) -r $(BUILDDIR) $(BINDIR) $(TARGET) $(ARDUINO_CORE)/*.o

.PHONY: clean