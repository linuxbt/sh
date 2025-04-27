#!/usr/bin/env bash

# BIP39 Mnemonic Manager for iOS Shell Environments (e.g., iSH, a-Shell with caveats)
# Based on a Termux script, modified for portability.
# Requires bash, python, openssl in the system's PATH.
# Author: AI Assistant
# Version: 1.15 - Adapted for non-Termux iOS environments, removed pkg dependency.

# --- Configuration ---
ENCRYPTION_ALGO="aes-256-cbc"
# OPENSSL_OPTS will be set dynamically based on PBKDF2 support
OPENSSL_OPTS="-${ENCRYPTION_ALGO} -a -salt" # Default, will be updated
MIN_PASSWORD_LENGTH=8

# --- Embedded BIP39 English Wordlist ---
# This list contains 2048 words as per BIP39 standard.
read -r -d '' BIP39_WORDLIST << 'EOF_WORDLIST'
abandon
ability
able
about
above
absent
absorb
abstract
absurd
abuse
access
accident
account
accuse
achieve
acid
acoustic
acquire
across
act
action
actor
actress
actual
adapt
add
addict
address
adjust
admit
adult
advance
advice
aerobic
affair
afford
afraid
again
age
agent
agree
ahead
aim
air
airport
aisle
alarm
album
alcohol
alert
alien
all
alley
allow
almost
alone
alpha
already
also
alter
always
amateur
amazing
among
amount
amused
analyst
anchor
ancient
anger
angle
angry
animal
ankle
announce
annual
another
answer
antenna
antique
anxiety
any
apart
apology
appear
apple
approve
april
arch
arctic
area
arena
argue
arm
armed
armor
army
around
arrange
arrest
arrive
arrow
art
artefact
artist
artwork
ask
aspect
assault
asset
assist
assume
asthma
athlete
atom
attack
attend
attitude
attract
auction
audit
august
aunt
author
auto
autumn
average
avocado
avoid
awake
aware
away
awesome
awful
awkward
axis
baby
bachelor
bacon
badge
bag
balance
balcony
ball
bamboo
banana
banner
bar
barely
bargain
barrel
base
basic
basket
battle
beach
bean
beauty
because
become
beef
before
begin
behave
behind
believe
below
belt
bench
benefit
best
betray
better
between
beyond
bicycle
bid
bike
bind
biology
bird
birth
bitter
black
blade
blame
blanket
blast
bleak
bless
blind
blood
blossom
blouse
blue
blur
blush
board
boat
body
boil
bomb
bone
bonus
book
boost
border
boring
borrow
boss
bottom
bounce
box
boy
bracket
brain
brand
brass
brave
bread
breeze
brick
bridge
brief
bright
bring
brisk
broccoli
broken
bronze
broom
brother
brown
brush
bubble
buddy
budget
buffalo
build
bulb
bulk
bullet
bundle
bunker
burden
burger
burst
bus
business
busy
butter
buyer
buzz
cabbage
cabin
cable
cactus
cage
cake
call
calm
camera
camp
can
canal
cancel
candy
cannon
canoe
canvas
canyon
capable
capital
captain
car
carbon
card
cargo
carpet
carry
cart
case
cash
casino
castle
casual
cat
catalog
catch
category
cattle
caught
cause
caution
cave
ceiling
celery
cement
census
century
cereal
certain
chair
chalk
champion
change
chaos
chapter
charge
chase
chat
cheap
check
cheese
chef
cherry
chest
chicken
chief
child
chimney
choice
choose
chronic
chuckle
chunk
churn
cigar
cinnamon
circle
citizen
city
civil
claim
clap
clarify
claw
clay
clean
clerk
clever
click
client
cliff
climb
clinic
clip
clock
clog
close
cloth
cloud
clown
club
clump
cluster
clutch
coach
coast
coconut
code
coffee
coil
coin
collect
color
column
combine
come
comfort
comic
common
company
concert
conduct
confirm
congress
connect
consider
control
convince
cook
cool
copper
copy
coral
core
corn
correct
cost
cotton
couch
country
couple
course
cousin
cover
coyote
crack
cradle
craft
cram
crane
crash
crater
crawl
crazy
cream
credit
creek
crew
cricket
crime
crisp
critic
crop
cross
crouch
crowd
crucial
cruel
cruise
crumble
crunch
crush
cry
crystal
cube
culture
cup
cupboard
curious
current
curtain
curve
cushion
custom
cute
cycle
dad
damage
damp
dance
danger
daring
dash
daughter
dawn
day
deal
debate
debris
decade
december
decide
decline
decorate
decrease
deer
defense
define
defy
degree
delay
deliver
demand
demise
denial
dentist
deny
depart
depend
deposit
depth
deputy
derive
describe
desert
design
desk
despair
destroy
detail
detect
develop
device
devote
diagram
dial
diamond
diary
dice
diesel
diet
differ
digital
dignity
dilemma
dinner
dinosaur
direct
dirt
disagree
discover
disease
dish
dismiss
disorder
display
distance
divert
divide
divorce
dizzy
doctor
document
dog
doll
dolphin
domain
donate
donkey
donor
door
dose
double
dove
draft
dragon
drama
drastic
draw
dream
dress
drift
drill
drink
drip
drive
drop
drum
dry
duck
dumb
dune
during
dust
dutch
duty
dwarf
dynamic
eager
eagle
early
earn
earth
easily
east
easy
echo
ecology
economy
edge
edit
educate
effort
egg
eight
either
elbow
elder
electric
elegant
element
elephant
elevator
elite
else
embark
embody
embrace
emerge
emotion
employ
empower
empty
enable
enact
end
endless
endorse
enemy
energy
enforce
engage
engine
enhance
enjoy
enlist
enough
enrich
enroll
ensure
enter
entire
entry
envelope
episode
equal
equip
era
erase
erode
erosion
error
erupt
escape
essay
essence
estate
eternal
ethics
evidence
evil
evoke
evolve
exact
example
excess
exchange
excite
exclude
excuse
execute
exercise
exhaust
exhibit
exile
exist
exit
exotic
expand
expect
expire
explain
expose
express
extend
extra
eye
eyebrow
fabric
face
faculty
fade
faint
faith
fall
false
fame
family
famous
fan
fancy
fantasy
farm
fashion
fat
fatal
father
fatigue
fault
favorite
feature
february
federal
fee
feed
feel
female
fence
festival
fetch
fever
few
fiber
fiction
field
figure
file
film
filter
final
find
fine
finger
finish
fire
firm
first
fiscal
fish
fit
fitness
fix
flag
flame
flash
flat
flavor
flee
flight
flip
float
flock
floor
flower
fluid
flush
fly
foam
focus
fog
foil
fold
follow
food
foot
force
forest
forget
fork
fortune
forum
forward
fossil
foster
found
fox
fragile
frame
frequent
fresh
friend
fringe
frog
front
frost
frown
frozen
fruit
fuel
fun
funny
furnace
fury
future
gadget
gain
galaxy
gallery
game
gap
garage
garbage
garden
garlic
garment
gas
gasp
gate
gather
gauge
gaze
general
genius
genre
gentle
genuine
gesture
ghost
giant
gift
giggle
ginger
giraffe
girl
give
glad
glance
glare
glass
glide
glimpse
globe
gloom
glory
glove
glow
glue
goat
goddess
gold
good
goose
gorilla
gospel
gossip
govern
gown
grab
grace
grain
grant
grape
grass
gravity
great
green
grid
grief
grit
grocery
group
grow
grunt
guard
guess
guide
guilt
guitar
gun
gym
habit
hair
half
hammer
hamster
hand
happy
harbor
hard
harsh
harvest
hat
have
hawk
hazard
head
health
heart
heavy
hedgehog
height
hello
helmet
help
hen
hero
hidden
high
hill
hint
hip
hire
history
hobby
hockey
hold
hole
holiday
hollow
home
honey
hood
hope
horn
horror
horse
hospital
host
hotel
hour
hover
hub
huge
human
humble
humor
hundred
hungry
hunt
hurdle
hurry
hurt
husband
hybrid
ice
icon
idea
identify
idle
ignore
ill
illegal
illness
image
imitate
immense
immune
impact
impose
improve
impulse
inch
include
income
increase
index
indicate
indoor
industry
infant
inflict
inform
inhale
inherit
initial
inject
injury
inmate
inner
innocent
input
inquiry
insane
insect
inside
inspire
install
intact
interest
into
invest
invite
involve
iron
island
isolate
issue
item
ivory
jacket
jaguar
jar
jazz
jealous
jeans
jelly
jewel
job
join
joke
journey
joy
judge
juice
jump
jungle
junior
junk
just
kangaroo
keen
keep
ketchup
key
kick
kid
kidney
kind
kingdom
kiss
kit
kitchen
kite
kitten
kiwi
knee
knife
knock
know
lab
label
labor
ladder
lady
lake
lamp
language
laptop
large
later
latin
laugh
laundry
lava
law
lawn
lawsuit
layer
lazy
leader
leaf
learn
leave
lecture
left
leg
legal
legend
leisure
lemon
lend
length
lens
leopard
lesson
letter
level
liar
liberty
library
license
life
lift
light
like
limb
limit
link
lion
liquid
list
little
live
lizard
load
loan
lobster
local
lock
logic
lonely
long
loop
lottery
loud
lounge
love
loyal
lucky
luggage
lumber
lunar
lunch
luxury
lyrics
machine
mad
magic
magnet
maid
mail
main
major
make
mammal
man
manage
mandate
mango
mansion
manual
maple
marble
march
margin
marine
market
marriage
mask
mass
master
match
material
math
matrix
matter
maximum
maze
meadow
mean
measure
meat
mechanic
medal
media
melody
melt
member
memory
mention
menu
mercy
merge
merit
merry
mesh
message
metal
method
middle
midnight
milk
million
mimic
mind
minimum
minor
minute
miracle
mirror
misery
miss
mistake
mix
mixed
mixture
mobile
model
modify
mom
moment
monitor
monkey
monster
month
moon
moral
more
morning
mosquito
mother
motion
motor
mountain
mouse
move
movie
much
muffin
mule
multiply
muscle
museum
mushroom
music
must
mutual
myself
mystery
myth
naive
name
napkin
narrow
nasty
nation
nature
near
neck
need
negative
neglect
neither
nephew
nerve
nest
net
network
neutral
never
news
next
nice
night
noble
noise
nominee
noodle
normal
north
nose
notable
note
nothing
notice
novel
now
nuclear
number
nurse
nut
oak
obey
object
oblige
obscure
observe
obtain
obvious
occur
ocean
october
odor
off
offer
office
often
oil
okay
old
olive
olympic
omit
once
one
onion
online
only
open
opera
opinion
oppose
option
orange
orbit
orchard
order
ordinary
organ
orient
original
orphan
ostrich
other
outdoor
outer
output
outside
oval
oven
over
own
owner
oxygen
oyster
ozone
pact
paddle
page
pair
palace
palm
panda
panel
panic
panther
paper
parade
parent
park
parrot
party
pass
patch
path
patient
patrol
pattern
pause
pave
payment
peace
peanut
pear
peasant
pelican
pen
penalty
pencil
people
pepper
perfect
permit
person
pet
phone
photo
phrase
physical
piano
picnic
picture
piece
pig
pigeon
pill
pilot
pink
pioneer
pipe
pistol
pitch
pizza
place
planet
plastic
plate
play
please
pledge
pluck
plug
plunge
poem
poet
point
polar
pole
police
pond
pony
pool
popular
portion
position
possible
post
potato
pottery
poverty
powder
power
practice
praise
predict
prefer
prepare
present
pretty
prevent
price
pride
primary
print
priority
prison
private
prize
problem
process
produce
profit
program
project
promote
proof
property
prosper
protect
proud
provide
public
pudding
pull
pulp
pulse
pumpkin
punch
pupil
puppy
purchase
purity
purpose
purse
push
put
puzzle
pyramid
quality
quantum
quarter
question
quick
quit
quiz
quote
rabbit
raccoon
race
rack
radar
radio
rail
rain
raise
rally
ramp
ranch
random
range
rapid
rare
rate
rather
raven
raw
razor
ready
real
reason
rebel
rebuild
recall
receive
recipe
record
recycle
reduce
reflect
reform
refuse
region
regret
regular
reject
relax
release
relief
rely
remain
remember
remind
remove
render
renew
rent
reopen
repair
repeat
replace
report
require
rescue
resemble
resist
resource
response
result
retire
retreat
return
reunion
reveal
review
reward
rhythm
rib
ribbon
rice
rich
ride
ridge
rifle
right
rigid
ring
riot
ripple
risk
ritual
rival
river
road
roast
robot
robust
rocket
romance
roof
rookie
room
rose
rotate
rough
round
route
royal
rubber
rude
rug
rule
run
runway
rural
sad
saddle
sadness
safe
sail
salad
salmon
salon
salt
salute
same
sample
sand
satisfy
satoshi
sauce
sausage
save
say
scale
scan
scare
scatter
scene
scheme
school
science
scissors
scorpion
scout
scrap
screen
script
scrub
sea
search
season
seat
second
secret
section
security
seed
seek
segment
select
sell
seminar
senior
sense
sentence
series
service
session
settle
setup
seven
shadow
shaft
shallow
share
shed
shell
sheriff
shield
shift
shine
ship
shiver
shock
shoe
shoot
shop
short
shoulder
shove
shrimp
shrug
shuffle
shy
sibling
sick
side
siege
sight
sign
silent
silk
silly
silver
similar
simple
since
sing
siren
sister
situate
six
size
skate
sketch
ski
skill
skin
skirt
skull
slab
slam
sleep
slender
slice
slide
slight
slim
slogan
slot
slow
slush
small
smart
smile
smoke
smooth
snack
snake
snap
sniff
snow
soap
soccer
social
sock
soda
soft
solar
soldier
solid
solution
solve
someone
song
soon
sorry
sort
soul
sound
soup
source
south
space
spare
spatial
spawn
speak
special
speed
spell
spend
sphere
spice
spider
spike
spin
spirit
split
spoil
sponsor
spoon
sport
spot
spray
spread
spring
spy
square
squeeze
squirrel
stable
stadium
staff
stage
stairs
stamp
stand
start
state
stay
steak
steel
stem
step
stereo
stick
still
sting
stock
stomach
stone
stool
story
stove
strategy
street
strike
strong
struggle
student
stuff
stumble
style
subject
submit
subway
success
such
sudden
suffer
sugar
suggest
suit
summer
sun
sunny
sunset
super
supply
supreme
sure
surface
surge
surprise
surround
survey
suspect
sustain
swallow
swamp
swap
swarm
swear
sweet
swift
swim
swing
switch
sword
symbol
symptom
syrup
system
table
tackle
tag
tail
talent
talk
tank
tape
target
task
taste
tattoo
taxi
teach
team
tell
ten
tenant
tennis
tent
term
test
text
thank
that
theme
then
theory
there
they
thing
this
thought
three
thrive
throw
thumb
thunder
ticket
tide
tiger
tilt
timber
time
tiny
tip
tired
tissue
title
toast
tobacco
today
toddler
toe
together
toilet
token
tomato
tomorrow
tone
tongue
tonight
tool
tooth
top
topic
topple
torch
tornado
tortoise
toss
total
tourist
toward
tower
town
toy
track
trade
traffic
tragic
train
transfer
trap
trash
travel
tray
treat
tree
trend
trial
tribe
trick
trigger
trim
trip
trophy
trouble
truck
true
truly
trumpet
trust
truth
try
tube
tuition
tumble
tuna
tunnel
turkey
turn
turtle
twelve
twenty
twice
twin
twist
two
type
typical
ugly
umbrella
unable
unaware
uncle
uncover
under
undo
unfair
unfold
unhappy
uniform
unique
unit
universe
unknown
unlock
until
unusual
unveil
update
upgrade
uphold
upon
upper
upset
urban
urge
usage
use
used
useful
useless
usual
utility
vacant
vacuum
vague
valid
valley
valve
van
vanish
vapor
various
vast
vault
vehicle
velvet
vendor
venture
venue
verb
verify
version
very
vessel
veteran
viable
vibrant
vicious
victory
video
view
village
vintage
violin
virtual
virus
visa
visit
visual
vital
vivid
vocal
voice
void
volcano
volume
vote
voyage
wage
wagon
wait
walk
wall
walnut
want
warfare
warm
warrior
wash
wasp
waste
water
wave
way
wealth
weapon
wear
weasel
weather
web
wedding
weekend
weird
welcome
west
wet
whale
what
wheat
wheel
when
where
whip
whisper
wide
width
wife
wild
will
win
window
wine
wing
wink
winner
winter
wire
wisdom
wise
wish
witness
wolf
woman
wonder
wood
wool
word
work
world
worry
worth
wrap
wreck
wrestle
wrist
write
wrong
yard
year
yellow
you
young
youth
zebra
zero
zone
EOF_WORDLIST

# --- Embedded Python Script for Mnemonic Generation ---
# This script generates a BIP39 mnemonic of a specified length (12, 18, or 24 words)
# from cryptographically secure random bytes using the provided wordlist.
# It relies only on standard Python libraries (os, hashlib, sys).
# It expects the wordlist on standard input and the desired word count as the first command-line argument.
read -r -d '' PYTHON_MNEMONIC_GENERATOR_SCRIPT << 'EOF_PYTHON_SCRIPT'
import sys
import os
import hashlib

# Read wordlist from stdin
wordlist = [line.strip() for line in sys.stdin if line.strip()]
if len(wordlist) != 2048:
    print("Error: Wordlist has incorrect number of words (expected 2048).", file=sys.stderr)
    sys.exit(1)

# Read desired word count from command line argument
if len(sys.argv) < 2:
    print("Error: No word count provided as argument.", file=sys.stderr)
    print("Usage: python script.py <word_count>", file=sys.stderr)
    sys.exit(1)

try:
    word_count = int(sys.argv[1])
except ValueError:
    print(f"Error: Invalid word count argument '{sys.argv[1]}'. Must be an integer.", file=sys.stderr)
    sys.exit(1)

# Determine entropy and checksum lengths based on word count
# BIP39 standard: Entropy length (bits) | Checksum length (bits) | Mnemonic length (words)
# 128 | 4 | 12
# 192 | 6 | 18
# 256 | 8 | 24
entropy_bytes_length = 0
checksum_bits_length = 0
total_bits_length = 0 # Total bits = entropy + checksum

if word_count == 12:
    entropy_bytes_length = 16 # 128 bits
    checksum_bits_length = 4
    total_bits_length = 132 # 128 + 4
elif word_count == 18:
    entropy_bytes_length = 24 # 192 bits
    checksum_bits_length = 6
    total_bits_length = 198 # 192 + 6
elif word_count == 24:
    entropy_bytes_length = 32 # 256 bits
    checksum_bits_length = 8
    total_bits_length = 264 # 256 + 8
else:
    print(f"Error: Invalid word count '{word_count}'. Must be 12, 18, or 24.", file=sys.stderr)
    sys.exit(1)

# Expected total bits must be word_count * 11
if total_bits_length != word_count * 11:
     print(f"Internal Error: Mismatch between word count ({word_count}) and calculated total bits ({total_bits_length}).", file=sys.stderr)
     sys.exit(1)

try:
    # Generate entropy using a secure source
    entropy_bytes = os.urandom(entropy_bytes_length)

    # Calculate checksum (first checksum_bits_length from SHA256 hash of entropy)
    checksum_full_bytes = hashlib.sha256(entropy_bytes).digest()
    # Extract the required number of checksum bits
    # Need to convert bytes to an integer and shift/mask
    checksum_int = int.from_bytes(checksum_full_bytes, 'big')

    # The first `checksum_bits_length` bits of the hash are the checksum.
    # The SHA256 hash is 256 bits. We want the top bits.
    # Shift right by 256 - checksum_bits_length to move the desired bits to the LSB position.
    # Mask with (1 << checksum_bits_length) - 1 to keep only those bits.
    checksum_value = (checksum_int >> (256 - checksum_bits_length)) & ((1 << checksum_bits_length) - 1)


    # Combine entropy and checksum bits
    # Convert entropy bytes to a large integer
    entropy_int = int.from_bytes(entropy_bytes, 'big')

    # The combined integer has total_bits_length bits.
    # The bits are arranged as [entropy][checksum] from MSB to LSB.
    # To combine, shift the entropy bits left by the number of checksum bits, then OR with the checksum value.
    combined_int = (entropy_int << checksum_bits_length) | checksum_value

    # Extract 11-bit chunks
    mnemonic_words = []

    # The k-th word index (0-indexed) comes from bits [k*11] to [(k+1)*11 - 1] (MSB is bit 0)
    # In terms of shifting from LSB (bit 0): shift right by (total_bits_length - (k+1)*11) and mask
    for i in range(word_count):
        # Extract the i-th 11-bit chunk from the left (MSB)
        # The index of the 11-bit chunk from LSB is total_bits_length - (i+1)*11
        shift = total_bits_length - (i + 1) * 11
        word_index = (combined_int >> shift) & 0x7FF # 0x7FF is 11 bits set to 1

        if word_index >= len(wordlist):
             # Should not happen with correct bit manipulation and wordlist size
             print(f"Internal Error: Calculated word index {word_index} is out of bounds (wordlist size {len(wordlist)}).", file=sys.stderr)
             sys.exit(1)
        mnemonic_words.append(wordlist[word_index])

    # Print the mnemonic separated by spaces
    print(' '.join(mnemonic_words))
    sys.stdout.flush()

except ImportError as e:
    print(f"Error: Missing standard Python module: {e}. Ensure your Python installation is complete.", file=sys.stderr)
    sys.exit(1)
except Exception as e:
    print(f"Error during mnemonic generation: {e}", file=sys.stderr)
    sys.exit(1)

EOF_PYTHON_SCRIPT

# --- Helper Functions ---

create_python_script_temp_file() {
    # Use standard /tmp directory for temporary files
    PYTHON_SCRIPT_TEMP_FILE=$(mktemp /tmp/mnemonic_gen_script.XXXXXX.py)
    if [[ ! -f "$PYTHON_SCRIPT_TEMP_FILE" ]]; then
        echo "Error: Failed to create temporary file for Python script in /tmp." >&2
        echo "Please check if /tmp directory is writable in your environment." >&2
        exit 1
    fi
    printf "%s" "$PYTHON_MNEMONIC_GENERATOR_SCRIPT" > "$PYTHON_SCRIPT_TEMP_FILE"
    # Use bash's built-in 'trap' to clean up the temp file and other vars on exit/signal
    # Use 'clear' conditionally as part of exit cleanup if running interactively
    trap 'rm -f "$PYTHON_SCRIPT_TEMP_FILE"; cleanup_vars; if command -v clear >/dev/null 2>&1 && [ -t 1 ]; then clear; fi' EXIT HUP INT TERM
}

check_dependencies() {
    echo "🚀 正在检查必要的依赖项 (openssl, python)..."
    local missing_cmd=()

    if ! command -v openssl >/dev/null 2>&1; then
        missing_cmd+=("openssl")
    else
        # Check if openssl supports -pbkdf2
        if openssl enc -help 2>&1 | grep -q -e '-pbkdf2'; then
             OPENSSL_OPTS="-${ENCRYPTION_ALGO} -pbkdf2 -a -salt"
             # echo "OpenSSL supports PBKDF2. Using: $OPENSSL_OPTS" # For debugging
        else
             OPENSSL_OPTS="-${ENCRYPTION_ALGO} -a -salt"
             echo "警告：您的 OpenSSL 版本可能较旧，不支持 PBKDF2 选项。" >&2
             echo "将使用默认的密钥派生函数，安全性稍低，建议升级 OpenSSL。" >&2
             # echo "Using: $OPENSSL_OPTS" # For debugging
        fi
    fi

    if ! command -v python >/dev/null 2>&1; then
        missing_cmd+=("python")
    fi

    if [ ${#missing_cmd[@]} -ne 0 ]; then
        echo "错误：未找到以下命令: ${missing_cmd[*]}。" >&2
        echo "您需要在您的 iOS Shell 环境中手动安装它们。" >&2
        echo "例如在 iSH 中使用 'apk add openssl python3' (如果 'python' 命令不可用，可能需要链接或使用 'python3' 替换)。" >&2
        echo "或者根据您使用的特定环境查找安装方法。" >&2
        exit 1
    fi

    # Check if 'python' command is python3 (common alias issue)
    if command -v python >/dev/null 2>&1; then
        if python -c 'import sys; print(sys.version_info.major)' 2>/dev/null | grep -q "^3"; then
             : # It's python3, good
        else
             echo "警告：找到 'python' 命令，但它不是 Python 3。此脚本需要 Python 3。" >&2
             echo "请检查您的环境配置，或尝试使用 'python3' 命令。" >&2
             # The script might still work if the python command points to a compatible python3,
             # but this warning helps diagnose issues.
        fi
    fi


    echo "✅ 所有必要的依赖项已在 PATH 中找到 (openssl, python)。"
    echo "------------------------------"
}


generate_mnemonic_internal() {
    local word_count="$1"
    local mnemonic=""
    local py_exit_code

    if [[ ! -f "$PYTHON_SCRIPT_TEMP_FILE" ]]; then
         echo "Error: Python script temporary file not found ($PYTHON_SCRIPT_TEMP_FILE)." >&2
         return 1
    fi

    # Pass the wordlist to the python script via stdin
    # The python script expects the word count as the first argument
    # The python script is executed directly using the 'python' command found in PATH
    mnemonic=$(printf "%s" "$BIP39_WORDLIST" | python "$PYTHON_SCRIPT_TEMP_FILE" "$word_count")
    py_exit_code=$?

    if [[ $py_exit_code -ne 0 ]] || [[ -z "$mnemonic" ]]; then
        echo "错误：生成助记词失败！" >&2
        echo "Python 退出码: $py_exit_code" >&2
        echo "请检查 Python 安装是否正确，以及 Python 脚本是否有执行权限 (虽然 mktemp 创建的通常有)." >&2
        return 1
    fi
    # Return the potentially multi-word string correctly
    printf "%s" "$mnemonic"
}

get_password() {
    local prompt_message=$1
    local password=""
    local password_confirm=""
    while true; do
        # Use -s for silent input, -r for raw input (prevent backslash issues)
        # Compatibility Note: read -s behavior can vary slightly across environments.
        read -rsp "$prompt_message (输入时不会显示，最少 $MIN_PASSWORD_LENGTH 位): " password
        echo # Newline after silent input
        if [[ -z "$password" ]]; then
            echo "错误：密码不能为空！请重新输入。"
            continue
        fi
        if [[ ${#password} -lt $MIN_PASSWORD_LENGTH ]]; then
            echo "错误：密码太短，至少需要 $MIN_PASSWORD_LENGTH 个字符。请重新输入。"
            continue
        fi
        read -rsp "请再次输入密码以确认: " password_confirm
        echo # Newline after silent input
        if [[ "$password" == "$password_confirm" ]]; then
            break
        else
            echo "错误：两次输入的密码不匹配！请重新输入。"
        fi
    done
    printf "%s" "$password" # Use printf for robustness
}

cleanup_vars() {
    # Unset potentially sensitive variables
    unset mnemonic password password_decrypt encrypted_string decrypted_mnemonic password_input encrypted_string_input chosen_word_count word_count_choice
    unset skip_main_pause
    # Ensure temp file is cleaned up by the trap
}

# --- MODIFIED FUNCTION: Encryption ---
perform_generation_and_encryption() {
    local chosen_word_count="$1"
    local mnemonic
    local password_input
    local encrypted_string
    local gen_exit_code
    local openssl_exit_code

    echo "正在生成 ${chosen_word_count} 位 BIP39 助记词 (不会显示)..."
    mnemonic=$(generate_mnemonic_internal "$chosen_word_count")
    gen_exit_code=$?

    if [[ $gen_exit_code -ne 0 ]] || [[ -z "$mnemonic" ]]; then
        echo "错误：助记词生成过程失败。请检查前面的错误信息。" >&2
        return 1
    fi

    echo "请输入用于加密助记词的密码。"
    password_input=$(get_password "设置加密密码")
    if [[ -z "$password_input" ]]; then
         echo "错误: 未能获取有效密码。" >&2
         unset mnemonic # Clean up potentially generated mnemonic before returning
         return 1
    # Add check for empty password from get_password just in case
    elif [[ -z "$password_input" ]]; then
        echo "错误: 密码为空。" >&2
        unset mnemonic
        return 1
    fi


    echo "正在使用 ${ENCRYPTION_ALGO} 加密助记词..."
    # Use -pass fd:3 3<<< to pass password via file descriptor 3
    # This leaves standard input (fd 0) free for the mnemonic data from the pipe
    # Use echo -n to ensure no trailing newline is added to the mnemonic before piping
    # Call 'openssl' from PATH
    encrypted_string=$(echo -n "$mnemonic" | openssl enc $OPENSSL_OPTS -pass fd:3 3<<<"$password_input")
    openssl_exit_code=$?

    unset password_input mnemonic # Clean sensitive vars immediately after use

    # Check openssl exit code and output
    if [[ $openssl_exit_code -ne 0 ]] || [[ -z "$encrypted_string" ]]; then
        echo "错误：加密失败！" >&2
        echo "请检查 openssl 是否正常工作以及权限问题。" >&2
        echo "OpenSSL 退出码: $openssl_exit_code" >&2
        echo "确保 openssl 命令在您的 PATH 中并且能够执行。" >&2
        # Depending on the error, openssl might print messages to stderr
        # Capture stderr if needed for more detailed debugging
        # encrypted_string=$(echo -n "$mnemonic" | openssl enc $OPENSSL_OPTS -pass fd:3 3<<<"$password_input" 2>&1)
        cleanup_vars # Ensure cleanup on error
        return 1
    fi

    echo "--------------------------------------------------"
    echo "✅ ${chosen_word_count} 位助记词已生成并加密成功！"
    echo "👇 请妥善备份以下【加密后的字符串】:"
    echo ""
    # Print the encrypted string (should be longer now)
    echo "$encrypted_string"
    echo ""
    echo "--------------------------------------------------"
    echo "⚠️ 重要提示："
    echo "   1. **务必记住** 您刚才设置的【密码】！"
    echo "   2. 没有正确的密码，上面的加密字符串将【无法解密】！"
    echo "   3. 助记词原文未在此过程中显示或保存。"
    echo "--------------------------------------------------"

    cleanup_vars # Ensure cleanup on success
}
# --- END MODIFIED FUNCTION: Encryption ---


# --- MODIFIED FUNCTION: Decryption ---
decrypt_and_display() {
    local encrypted_string_input=""
    local line
    local password_input
    local decrypted_mnemonic
    local openssl_exit_code
    local word_count

    echo "--------------------------------------------------"
    echo "⚠️ 警告：请确保在手机系统，输入法,周围物理环境安全的情况下执行此操作！"
    echo "⚠️ 警告：强烈建议在断开网络连接（例如开启飞行模式）的情况下执行此操作！"
    echo "⚠️ 警告：强烈建议在执行完此操作，保存好加密字符串和记住密码的情况下重启设备！"
    echo "--------------------------------------------------"
    read -p "按 Enter 键继续，或按 Ctrl+C 取消..."

    echo "请粘贴之前保存的【加密字符串】："
    echo "（粘贴完成后，请【单独输入一个空行】并按 Enter 键结束）"
    # Read multi-line input from user until an empty line is entered
    while IFS= read -r line; do
        [[ -z "$line" ]] && break
        encrypted_string_input+="$line"$'\n'
    done
    # Remove the trailing newline if it was added by the last read line before break
    encrypted_string_input="${encrypted_string_input%$'\n'}"


    if [[ -z "$encrypted_string_input" ]]; then
        echo "错误：未输入加密字符串。" >&2
        cleanup_vars
        return 1
    fi

    echo "请输入解密密码。"
    password_input=$(get_password "输入解密密码")
    if [[ -z "$password_input" ]]; then
        echo "错误: 无法获取有效密码。" >&2
        cleanup_vars
        return 1
    fi

    echo "正在尝试解密..."
    # Use -pass fd:3 3<<< to pass password via file descriptor 3
    # This leaves standard input (fd 0) free for the encrypted data piped from printf
    # Use printf %s to ensure the potentially multi-line string is piped exactly as read
    # Call 'openssl' from PATH
    decrypted_mnemonic=$(printf "%s" "$encrypted_string_input" | openssl enc -d $OPENSSL_OPTS -pass fd:3 3<<<"$password_input" 2>/dev/null)
    openssl_exit_code=$?

    unset password_input # Clean password immediately

    if [[ $openssl_exit_code -ne 0 ]]; then
        echo "--------------------------------------------------"
        echo "❌ 错误：解密失败！" >&2
        echo "   - 请检查加密字符串和密码是否正确。" >&2
        echo "   - OpenSSL 解密错误，可能是密码错误或数据损坏。" >&2
        echo "   (OpenSSL 退出码: $openssl_exit_code)" >&2
        echo "--------------------------------------------------"
        cleanup_vars
        return 1
    fi

    # Validate the decrypted output looks like a mnemonic
    # Check word count and simple format (space separated)
    word_count=$(echo "$decrypted_mnemonic" | wc -w)
    # Basic check: is it a string of words separated by single spaces and only contains lowercase letters and spaces?
    # This is not a full BIP39 validation, but checks if it's plausible output.
    if [[ -z "$decrypted_mnemonic" || ! ( "$word_count" -eq 12 || "$word_count" -eq 18 || "$word_count" -eq 24 ) || ! $(echo "$decrypted_mnemonic" | grep -q "^[a-z ]\+$" && echo "valid") == "valid" ]]; then
        echo "--------------------------------------------------"
        echo "❌ 错误：解密结果无效或格式不正确！" >&2
        echo "   (解密后检测到 ${word_count} 个单词，预期 12, 18 或 24 个，且应为小写字母和空格组成)" >&2
        echo "   请检查加密字符串和密码是否正确。" >&2
        echo "--------------------------------------------------"
        cleanup_vars
        unset decrypted_mnemonic
        return 1
    fi


    echo "--------------------------------------------------"
    echo "✅ 解密成功！您的 ${word_count} 位 BIP39 助记词是:"
    echo ""
    # Display the decrypted mnemonic
    echo "$decrypted_mnemonic"
    echo ""
    echo "--------------------------------------------------"
    echo "⚠️ 请立即抄写助记词并妥善保管！"
    read -n 1 -s -r -p "按任意键清除屏幕并返回主菜单..." # -n 1 reads only one character
    # Clear screen only if 'clear' command exists, is executable, and output is a terminal
    if command -v clear >/dev/null 2>&1 && [ -t 1 ]; then
        clear
    fi
    cleanup_vars
    unset decrypted_mnemonic

}
# --- END MODIFIED FUNCTION: Decryption ---


# --- 脚本入口 ---

# Create the temporary Python script file
create_python_script_temp_file

# Check for necessary dependencies (python, openssl) in the PATH
check_dependencies

skip_main_pause=false # Flag to control pause before main menu

while true; do
    if ! $skip_main_pause; then
       # Clear screen only if 'clear' command exists, is executable, and output is a terminal
       if command -v clear >/dev/null 2>&1 && [ -t 1 ]; then
           clear
       fi
    fi

    echo ""
    echo "=================================================="
    echo "       BIP39 助记词安全管理器"
    echo "        (适用于 iOS Shell 环境)"
    echo "=================================================="
    echo "--------------------------------------------------"
    echo "⚠️ 警告：请确保在手机系统，输入法,周围物理环境安全的情况下执行此操作！"
    echo "⚠️ 警告：强烈建议在断开网络连接（例如开启飞行模式）的情况下执行此操作！"
    echo "⚠️ 警告：强烈建议在执行完，保存好加密字符串和记住密码的情况下重启设备！"
    echo "--------------------------------------------------"
    echo "请选择操作:"
    echo "  1. 生成新的 BIP39 助记词并加密保存"
    echo "  2. 解密已保存的字符串以查看助记词"
    echo "  q. 退出脚本"
    echo "------------------------------"
    read -p "请输入选项 [1/2/q]: " choice

    case "$choice" in
        1)
            if command -v clear >/dev/null 2>&1 && [ -t 1 ]; then
                clear
            fi
            # Variables for word count selection
            local word_count_choice=""
            local chosen_word_count=""

            while true; do
                echo ""
                echo "--------------------------------------------------"
                echo "⚠️ 警告：请确保在手机系统，输入法,周围物理环境安全的情况下执行此操作！"
                echo "⚠️ 警告：强烈建议在断开网络连接（例如开启飞行模式）的情况下执行此操作！"
                echo "⚠️ 警告：强烈建议在执行完此操作，保存好加密字符串和记住密码的情况下重启设备！"
                echo "--------------------------------------------------"

                echo "------------------------------"
                echo "  生成助记词 - 选择长度"
                echo "------------------------------"
                echo "请选择要生成的助记词长度："
                echo "  1. 12 个单词 (128位熵)"
                echo "  2. 18 个单词 (192位熵)"
                echo "  3. 24 个单词 (256位熵) - 推荐安全级别"
                echo "  b. 返回主菜单"
                echo "------------------------------"
                read -p "请输入选项 [1/2/3/b]: " word_count_choice

                case "$word_count_choice" in
                    1) chosen_word_count=12; break;;
                    2) chosen_word_count=18; break;;
                    3) chosen_word_count=24; break;;
                    b | B) echo "返回主菜单..."; chosen_word_count=""; break;;
                    *) echo "无效选项 '$word_count_choice'，请重新输入。"; sleep 1;;
                esac
            done

            if [[ -n "$chosen_word_count" ]]; then
                perform_generation_and_encryption "$chosen_word_count"
                skip_main_pause=false # Pause after encryption
            else
                skip_main_pause=true # No pause if returning to main menu
            fi
            # Unset local vars
            unset word_count_choice chosen_word_count
            ;;

        2)
            if command -v clear >/dev/null 2>&1 && [ -t 1 ]; then
                clear
            fi
            decrypt_and_display
            skip_main_pause=true # The decrypt function has its own pause
            ;;

        q | Q)
            echo "正在退出..."
            exit 0
            ;;

        *)
            echo "无效选项 '$choice'，请重新输入。"
            skip_main_pause=false # Pause after invalid input
            sleep 1
            ;;
    esac

    # Pause before showing the main menu again, unless skipped
    if [ "$skip_main_pause" = "false" ]; then
        echo ""
        read -n 1 -s -r -p "按任意键返回主菜单..."
    fi
    # Reset skip flag for the next loop iteration
    skip_main_pause=false

done
