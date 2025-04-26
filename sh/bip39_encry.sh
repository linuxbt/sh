#!/data/data/com.termux/files/usr/bin/env bash

# BIP39 Mnemonic Manager for Termux (Standalone)
# Author: AI Assistant
# Version: 1.7 - Skip main pause when returning from sub-menu

# --- Configuration ---
# 加密算法 (确保 Termux 的 openssl 支持)
# AES-256-CBC 是广泛支持且安全的选项
# -pbkdf2 使用更安全的密钥派生函数 (需要 OpenSSL 1.1.1+)
ENCRYPTION_ALGO="aes-256-cbc"
# OPENSSL_OPTS="-${ENCRYPTION_ALGO} -pbkdf2 -a -salt" # 默认使用 PBKDF2
OPENSSL_OPTS="-${ENCRYPTION_ALGO} -a -salt" # 先不默认加 -pbkdf2，在检查时根据 OpenSSL 版本决定
MIN_PASSWORD_LENGTH=8 # 密码最小长度
# --- Embedded BIP39 English Wordlist ---
# (此列表包含完整的 2048 个单词，脚本仅显示前几行作为示例，不会在运行时输出完整列表)
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
zoo
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

# Create a temporary file for the Python script and set a trap for cleanup
create_python_script_temp_file() {
    # Ensure tmp directory exists and is writable in Termux
    mkdir -p /data/data/com.termux/files/usr/tmp || { echo "Error: Failed to create temp directory."; exit 1; }
    PYTHON_SCRIPT_TEMP_FILE=$(mktemp /data/data/com.termux/files/usr/tmp/mnemonic_gen_script.XXXXXX.py)
    if [[ ! -f "$PYTHON_SCRIPT_TEMP_FILE" ]]; then
        echo "Error: Failed to create temporary file for Python script in /data/data/com.termux/files/usr/tmp." >&2
        exit 1
    fi
    # Write the embedded Python script content to the temp file
    printf "%s" "$PYTHON_MNEMONIC_GENERATOR_SCRIPT" > "$PYTHON_SCRIPT_TEMP_FILE"
    # Set a trap to remove the temp file on exit
    trap "rm -f \"$PYTHON_SCRIPT_TEMP_FILE\"; cleanup_vars" EXIT
    # echo "Debug: Python script temp file created: $PYTHON_SCRIPT_TEMP_FILE" # Debugging line
}

# Note: cleanup_python_script_temp_file function is implicitly handled by the trap.
# No need for a separate function call unless you want to manually remove it early (not recommended with trap).

# 检查并安装必要的命令
install_dependencies() {
    echo "🚀 正在检查和安装必要的依赖项..."

    local missing_pkg=()

    # 检查 Termux 包管理器 pkg
    if ! command -v pkg >/dev/null 2>&1; then
        echo "错误：Termux 包管理器 'pkg' 未找到！请确保您在 Termux 环境中运行此脚本。" >&2
        exit 1
    fi

    # 检查 OpenSSL
    if ! command -v openssl >/dev/null 2>&1; then
        missing_pkg+=("openssl-tool")
    else
        # 检查 OpenSSL 版本是否支持 PBKDF2
        # 使用 -pass arg to check command line options reliably
        if openssl enc -help 2>&1 | grep -q -e '-pbkdf2'; then
             OPENSSL_OPTS="-${ENCRYPTION_ALGO} -pbkdf2 -a -salt" # 如果支持 PBKDF2 则使用
             # echo "Debug: OpenSSL supports PBKDF2. Using: $OPENSSL_OPTS" # Debugging line
        else
             OPENSSL_OPTS="-${ENCRYPTION_ALGO} -a -salt" # 否则不使用
             echo "警告：您的 OpenSSL 版本可能较旧，不支持 PBKDF2 选项。" >&2
             echo "将使用默认的密钥派生函数，安全性稍低，建议升级 OpenSSL。" >&2
             # echo "Debug: OpenSSL does not support PBKDF2. Using: $OPENSSL_OPTS" # Debugging line
        fi
    fi


    # 检查 Python (用于执行嵌入的生成脚本)
    if ! command -v python >/dev/null 2>&1; then
        missing_pkg+=("python")
    fi

    # 如果有 Termux 包缺失，先安装这些包
    if [ ${#missing_pkg[@]} -ne 0 ]; then
        echo "安装 Termux 包: ${missing_pkg[*]}"
        pkg update -y
        if ! pkg install "${missing_pkg[@]}" -y; then
            echo "错误：安装 Termux 依赖失败。请检查您的网络连接或 Termux 环境。" >&2
            echo "尝试手动安装: pkg install ${missing_pkg[*]} -y" >&2
            exit 1
        fi
    fi

    # 再次检查 Python，确保它已被安装 (如果之前缺失的话)
    if ! command -v python >/dev/null 2>&1; then
         echo "错误：安装 Python 后仍然未找到 'python' 命令。请手动检查安装过程。" >&2
         exit 1
    fi

    echo "✅ 所有必要的依赖项已满足 (openssl, python)。"
    echo "------------------------------"
}


# 生成指定位数的 BIP39 助记词 (使用嵌入的 Python 脚本和单词列表)
# 这个函数只应该被内部调用，并且其输出绝不直接打印到主脚本的 stdout
# 参数: $1 - 助记词单词数量 (12, 18, 24)
generate_mnemonic_internal() {
    local word_count="$1" # Keep local here as this is a function

    # Ensure temp file exists before using it
    if [[ ! -f "$PYTHON_SCRIPT_TEMP_FILE" ]]; then
         echo "Error: Python script temporary file not found." >&2
         return 1
    fi

    local mnemonic="" # Keep local here as this is a function
    # Execute the embedded Python script, piping the wordlist to its stdin
    # Pass the word count as a command-line argument to the Python script
    # Using printf "%s" ensures no trailing newline from the wordlist HEREDOC.
    mnemonic=$(printf "%s" "$BIP39_WORDLIST" | python "$PYTHON_SCRIPT_TEMP_FILE" "$word_count")
    local py_exit_code=$? # Keep local here as this is a function

    if [[ $py_exit_code -ne 0 ]] || [[ -z "$mnemonic" ]]; then
        echo "错误：生成助记词失败！" >&2
        echo "请检查 Python 环境或嵌入的生成脚本是否有问题。" >&2
        echo "Python 退出码: $py_exit_code" >&2
        # cleanup_vars is handled by the trap set by create_python_script_temp_file
        return 1 # 返回错误状态
    fi
    # echo "Debug: Mnemonic generated (length: ${#mnemonic})" # 仅用于调试，生产中注释掉

    # Return the generated mnemonic by printing it
    printf "%s" "$mnemonic"
}

# 获取并验证密码
get_password() {
    local prompt_message=$1 # Keep local
    local password="" # Keep local
    local password_confirm="" # Keep local
    while true; do
        read -sp "$prompt_message (输入时不会显示，最少 $MIN_PASSWORD_LENGTH 位): " password
        echo # 换行
        if [[ -z "$password" ]]; then
            echo "错误：密码不能为空！请重新输入。"
            continue
        fi
        if [[ ${#password} -lt $MIN_PASSWORD_LENGTH ]]; then
            echo "错误：密码太短，至少需要 $MIN_PASSWORD_LENGTH 个字符。请重新输入。"
            continue
        fi
        # 基础复杂度检查：可以根据需要添加更多规则 (例如: =~ [A-Z] && =~ [a-z] && =~ [0-9])
        # 为了通用性，这里只检查长度
        read -sp "请再次输入密码以确认: " password_confirm
        echo # 换行
        if [[ "$password" == "$password_confirm" ]]; then
            break
        else
            echo "错误：两次输入的密码不匹配！请重新输入。"
        fi
    done
    # 将密码存储在提供的变量名中 (通过 caller)
    # 注意：这里我们将密码直接返回给调用者处理，而不是存储在全局变量中
    # 调用者负责在使用后 unset 变量
     printf "%s" "$password" # 使用 printf avoids trailing newline
}

# 清理敏感变量
cleanup_vars() {
    # Note: PYTHON_SCRIPT_TEMP_FILE is cleaned by the trap.
    # These variables are used across functions or in the main loop, so they are not 'local'
    unset mnemonic password password_decrypt encrypted_string decrypted_mnemonic password_input encrypted_string_input chosen_word_count word_count_choice
    # Variables used by the flag logic in the main loop:
    unset skip_main_pause
    # echo "Debug: Sensitive variables cleared." # 用于调试
}

# 执行生成和加密的函数 (接受单词数量作为参数)
perform_generation_and_encryption() {
    local chosen_word_count="$1" # Keep local here as this is a function

    echo "正在生成 ${chosen_word_count} 位 BIP39 助记词 (不会显示)..."
    local mnemonic # Keep local
    # 捕获内部函数的输出到变量，而不是打印
    mnemonic=$(generate_mnemonic_internal "$chosen_word_count")
    local gen_exit_code=$? # Keep local

    if [[ $gen_exit_code -ne 0 ]] || [[ -z "$mnemonic" ]]; then
        echo "错误：助记词生成过程失败。请检查前面的错误信息。" >&2
        # cleanup_vars is called by the trap on exit or explicit call
        return 1 # 返回错误状态
    fi
    # echo "Debug: Mnemonic generated (length: ${#mnemonic}, first 3 words: $(echo "$mnemonic" | cut -d ' ' -f 1-3))" # 仅用于调试

    local password_input # Keep local
    echo "请输入用于加密助记词的密码。"
    password_input=$(get_password "设置加密密码")
    if [[ -z "$password_input" ]]; then
         echo "错误: 未能获取有效密码。" >&2
         # cleanup_vars is called by the trap on exit or explicit call
         return 1
    fi

    echo "正在使用 ${ENCRYPTION_ALGO} 加密助记词..."
    local encrypted_string # Keep local
    # 使用 heredoc 将助记词传递给 openssl stdin, using printf "%s" to prevent trailing newline
    # 使用 -pass pass:"$password" 直接传递密码
    # IMPORTANT: openssl enc output includes Salted__ header and base64.
    # Using "-a" for base64 encoding.
    # hash -r # Force shell to re-find openssl
    encrypted_string=$(printf "%s" "$mnemonic" | /data/data/com.termux/files/usr/bin/openssl enc $OPENSSL_OPTS -pass pass:"$password_input")

    local openssl_exit_code=$? # Keep local

    if [[ $openssl_exit_code -ne 0 ]] || [[ -z "$encrypted_string" ]]; then
        echo "错误：加密失败！" >&2
        echo "请检查 openssl 是否正常工作或密码是否有特殊字符导致问题。" >&2
        echo "OpenSSL 退出码: $openssl_exit_code" >&2
        # cleanup_vars is called by the trap on exit or explicit call
        return 1
    fi

    echo "--------------------------------------------------"
    echo "✅ ${chosen_word_count} 位助记词已生成并加密成功！"
    echo "👇 请妥善备份以下【加密后的字符串】:"
    echo ""
    echo "$encrypted_string"
    echo ""
    echo "--------------------------------------------------"
    echo "⚠️ 重要提示："
    echo "   1. **务必记住** 您刚才设置的【密码】！"
    echo "   2. 没有正确的密码，上面的加密字符串将【无法解密】！"
    echo "   3. 助记词原文未在此过程中显示或保存。"
    echo "--------------------------------------------------"

    # 操作完成后清理敏感变量
    cleanup_vars
}


# 选项 2: 解密并显示
decrypt_and_display() {
    echo "--------------------------------------------------"
    echo "⚠️ 警告：强烈建议在断开网络连接（例如开启飞行模式）的情况下执行此操作！"
    echo "--------------------------------------------------"
    read -p "按 Enter 键继续，或按 Ctrl+C 取消..."
    local encrypted_string_input # Keep local
    echo "请粘贴之前保存的【加密字符串】："
    echo "（粘贴完成后，请按一次 Enter 键，然后输入 Ctrl+D 结束输入）" # Clarified input method
    # 使用特殊方法读取多行输入，直到遇到空行 或 EOF (Ctrl+D)
    encrypted_string_input=$(cat -) # reads until EOF (Ctrl+D) or an empty line on some systems
    # Strip the last empty line if present (some terminals send empty line on Enter)
    encrypted_string_input=$(echo "$encrypted_string_input" | sed '/^$/d' )

    if [[ -z "$encrypted_string_input" ]]; then
        echo "错误：未输入加密字符串。" >&2
        cleanup_vars
        return 1
    fi

    local password_input # Keep local
    echo "请输入解密密码。"
    password_input=$(get_password "输入解密密码")
    if [[ -z "$password_input" ]]; then
        echo "错误: 无法获取有效密码。" >&2
        cleanup_vars
        return 1
    fi

    echo "正在尝试解密..."
    local decrypted_mnemonic # Keep local
    # Pipe the input string to openssl. openssl needs the base64 input.
    decrypted_mnemonic=$(printf "%s" "$encrypted_string_input" | /data/data/com.termux/files/usr/bin/openssl enc -d $OPENSSL_OPTS -pass pass:"$password_input" 2> /dev/null)
    local openssl_exit_code=$? # Keep local

    if [[ $openssl_exit_code -ne 0 ]]; then
        echo "--------------------------------------------------"
        echo "❌ 错误：解密失败！" >&2
        echo "   - 请检查加密字符串和密码是否正确。" >&2
        echo "   (OpenSSL 退出码: $openssl_exit_code)" >&2
        echo "--------------------------------------------------"
        cleanup_vars
        return 1
    fi

    # Check if the decrypted result looks like a valid mnemonic (at least the word count)
    local word_count=$(echo "$decrypted_mnemonic" | wc -w) # Keep local
    # BIP39 standard supports 12, 15, 18, 21, 24 words. Our generator only does 12, 18, 24.
    # A simple check for 12, 18, or 24 is sufficient for strings generated by *this* script.
    if [[ -z "$decrypted_mnemonic" || ! ( "$word_count" -eq 12 || "$word_count" -eq 18 || "$word_count" -eq 24 ) ]]; then
        echo "--------------------------------------------------"
        echo "❌ 错误：解密结果无效或格式不正确！" >&2
        echo "   (解密后检测到 ${word_count} 个单词，预期 12, 18 或 24 个)" >&2
        echo "   请检查加密字符串和密码是否正确。" >&2
        echo "--------------------------------------------------"
        cleanup_vars
        return 1
    fi

    echo "--------------------------------------------------"
    echo "✅ 解密成功！您的 ${word_count} 位 BIP39 助记词是:"
    echo ""
    echo "$decrypted_mnemonic"
    echo ""
    echo "--------------------------------------------------"
    # 清理敏感变量
    cleanup_vars
}


# --- 脚本入口 ---

# 首先创建临时的 Python 脚本文件并设置清理 trap
create_python_script_temp_file

# 然后检查并安装依赖
install_dependencies

# Flag to control skipping the main pause prompt
skip_main_pause=false # This variable is used in the main loop, outside of functions

# Main menu loop
while true; do
    echo ""
    echo "=============================="
    echo "  BIP39 助记词安全管理器"
    echo "=============================="
    echo "请选择操作:"
    echo "  1. 生成新的 BIP39 助记词并加密保存"
    echo "  2. 解密已保存的字符串以查看助记词"
    echo "  q. 退出脚本"
    echo "------------------------------"
    read -p "请输入选项 [1/2/q]: " choice

    case "$choice" in
        1)
            # Variables used within this case block (not in a function) should not be 'local'
            word_count_choice=""
            chosen_word_count=""

            # Sub-menu loop for word count selection
            while true; do
                echo "" # Add newline for clarity
                echo "------------------------------"
                echo "  生成助记词 - 选择长度"
                echo "------------------------------"
                echo "请选择要生成的助记词长度："
                echo "  1. 12 个单词 (128位熵)"
                echo "  2. 18 个单词 (192位熵)"
                echo "  3. 24 个单词 (256位熵) - 推荐安全级别"
                echo "  b. 返回主菜单"
                echo "------------------------------"
                # Prompt using 1, 2, 3
                read -p "请输入选项 [1/2/3/b]: " word_count_choice

                # Map user input (1, 2, 3) to actual word count (12, 18, 24)
                case "$word_count_choice" in
                    1) chosen_word_count=12; break;; # User chose 1, meaning 12 words
                    2) chosen_word_count=18; break;; # User chose 2, meaning 18 words
                    3) chosen_word_count=24; break;; # User chose 3, meaning 24 words
                    b | B) echo "返回主菜单..."; chosen_word_count=""; break;; # Back to main menu, clear choice
                    *) echo "无效选项 '$word_count_choice'，请重新输入。";;
                esac
            done # End of sub-menu loop

            # After inner loop breaks:
            if [[ -z "$chosen_word_count" ]]; then # If user chose 'b'
                skip_main_pause=true # Set flag to skip the main pause later
            else
                # If user chose a word count, perform the generation and encryption
                perform_generation_and_encryption "$chosen_word_count"
                skip_main_pause=false # Ensure pause happens after a successful operation
            fi
            ;; # End of main case 1

        2)
            decrypt_and_display
            skip_main_pause=false # Ensure pause happens after decryption
            ;;

        q | Q)
            echo "正在退出..."
            # Trap will handle cleanup
            # Explicitly call cleanup_vars one last time for safety
            cleanup_vars
            sleep 1
            clear
            exit 0
            ;;

        *)
            echo "无效选项 '$choice'，请重新输入。"
            skip_main_pause=false # Ensure pause happens after invalid input
            ;;
    esac # Main case ends

    # --- Pause before showing main menu again ---
    # Skip pause if the flag is set (user chose 'b' in sub-menu)
    if [ "$skip_main_pause" = "false" ]; then
        echo "" # 在提示前加一行空行，美观一些
        read -n 1 -s -r -p "按任意键返回主菜单..."
        echo # Newline after prompt
    fi
    # Reset the flag regardless, so the next loop iteration doesn't skip automatically
    skip_main_pause=false

done # Main loop ends
