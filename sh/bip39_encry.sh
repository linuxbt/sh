#!/data/data/com.termux/files/usr/bin/env bash

# BIP39 Mnemonic Manager for Termux (Standalone)
# Author: AI Assistant
# Version: 1.3 - Embedded wordlist and standalone Python generation

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
# This script generates a 24-word BIP39 mnemonic from cryptographically
# secure random bytes using the provided wordlist.
# It relies only on standard Python libraries (os, hashlib, sys).
# It takes the wordlist on standard input and prints the mnemonic to standard output.
read -r -d '' PYTHON_MNEMONIC_GENERATOR_SCRIPT << 'EOF_PYTHON_SCRIPT'
import sys
import os
import hashlib

# Read wordlist from stdin
wordlist = [line.strip() for line in sys.stdin if line.strip()]
if len(wordlist) != 2048:
    print("Error: Wordlist has incorrect number of words.", file=sys.stderr)
    sys.exit(1)

try:
    # Generate 256 bits of entropy (32 bytes) using a secure source
    entropy_bytes = os.urandom(32)

    # Calculate checksum (first byte of SHA256 hash of entropy)
    checksum_byte = hashlib.sha256(entropy_bytes).digest()[0]

    # Combine entropy and checksum bits
    # Total 256 (entropy) + 8 (checksum) = 264 bits
    # Convert bytes to a large integer
    all_bits_int = int.from_bytes(entropy_bytes, 'big') << 8 | checksum_byte

    # Extract 11-bit chunks (24 words * 11 bits/word = 264 bits)
    mnemonic_words = []
    for i in range(24):
        # Extract the i-th 11-bit chunk from the left (MSB)
        # The index of the 11-bit chunk from MSB is 23-i
        # Shift right by (23-i) * 11 bits
        # Mask with 0x7FF (binary 11111111111) to get the last 11 bits
        shift = (23 - i) * 11
        word_index = (all_bits_int >> shift) & 0x7FF
        if word_index >= len(wordlist):
             # Should not happen with correct bit manipulation and wordlist size
             print(f"Error: Calculated word index {word_index} is out of bounds.", file=sys.stderr)
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
    PYTHON_SCRIPT_TEMP_FILE=$(mktemp /data/data/com.termux/files/usr/tmp/mnemonic_gen_script.XXXXXX.py)
    if [[ ! -f "$PYTHON_SCRIPT_TEMP_FILE" ]]; then
        echo "Error: Failed to create temporary file for Python script." >&2
        exit 1
    fi
    # Write the embedded Python script content to the temp file
    printf "%s" "$PYTHON_MNEMONIC_GENERATOR_SCRIPT" > "$PYTHON_SCRIPT_TEMP_FILE"
    # Set a trap to remove the temp file on exit
    trap "rm -f \"$PYTHON_SCRIPT_TEMP_FILE\"; cleanup_vars" EXIT
    # echo "Debug: Python script temp file created: $PYTHON_SCRIPT_TEMP_FILE" # Debugging line
}

# Remove the temporary Python script file
cleanup_python_script_temp_file() {
    if [[ -n "$PYTHON_SCRIPT_TEMP_FILE" ]] && [[ -f "$PYTHON_SCRIPT_TEMP_FILE" ]]; then
        # echo "Debug: Cleaning up temp file: $PYTHON_SCRIPT_TEMP_FILE" # Debugging line
        rm -f "$PYTHON_SCRIPT_TEMP_FILE"
    fi
    # Remove the trap after explicit cleanup
    trap - EXIT
}


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
        missing_pkg+=("openssl")
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


# 生成 24 位 BIP39 助记词 (使用嵌入的 Python 脚本和单词列表)
# 这个函数只应该被内部调用，并且其输出绝不直接打印到主脚本的 stdout
generate_mnemonic_internal() {
    # Ensure temp file exists before using it
    if [[ ! -f "$PYTHON_SCRIPT_TEMP_FILE" ]]; then
         echo "Error: Python script temporary file not found." >&2
         return 1
    fi

    local mnemonic=""
    # Execute the embedded Python script, piping the wordlist to its stdin
    # Use process substitution <() for wordlist to avoid large heredoc here
    mnemonic=$(python "$PYTHON_SCRIPT_TEMP_FILE" <<< "$BIP39_WORDLIST")
    local py_exit_code=$?

    if [[ $py_exit_code -ne 0 ]] || [[ -z "$mnemonic" ]]; then
        echo "错误：生成助记词失败！" >&2
        echo "请检查 Python 环境或嵌入的生成脚本是否有问题。" >&2
        echo "Python 退出码: $py_exit_code" >&2
        cleanup_vars # 清理可能的残留
        return 1 # 返回错误状态
    fi
    # echo "Debug: Mnemonic generated (length: ${#mnemonic})" # 仅用于调试，生产中注释掉

    # Return the generated mnemonic by printing it
    printf "%s" "$mnemonic"
}

# 获取并验证密码
get_password() {
    local prompt_message=$1
    local password=""
    local password_confirm=""
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
     printf "%s" "$password" # 使用 printf 避免换行符
}

# 清理敏感变量
cleanup_vars() {
    unset mnemonic password password_decrypt encrypted_string decrypted_mnemonic password_input encrypted_string_input
    # echo "Debug: Sensitive variables cleared." # 用于调试
}

# --- 主逻辑 ---

# 选项 1: 生成并加密
generate_and_encrypt() {
    echo "正在生成 24 位 BIP39 助记词 (不会显示)..."
    local mnemonic
    # 捕获内部函数的输出到变量，而不是打印
    mnemonic=$(generate_mnemonic_internal)
    local gen_exit_code=$?

    if [[ $gen_exit_code -ne 0 ]] || [[ -z "$mnemonic" ]]; then
        echo "错误：助记词生成过程失败。请检查前面的错误信息。" >&2
        cleanup_vars # 清理可能的残留
        return 1 # 返回错误状态
    fi
    # echo "Debug: Mnemonic generated (length: ${#mnemonic}, first 3 words: $(echo "$mnemonic" | cut -d ' ' -f 1-3))" # 仅用于调试

    local password_input
    echo "请输入用于加密助记词的密码。"
    password_input=$(get_password "设置加密密码")
    if [[ -z "$password_input" ]]; then
         echo "错误: 未能获取有效密码。" >&2
         cleanup_vars
         return 1
    fi

    echo "正在使用 ${ENCRYPTION_ALGO} 加密助记词..."
    local encrypted_string
    # 使用 heredoc 将助记词传递给 openssl stdin，避免在命令行参数中暴露
    # 使用 -pass pass:"$password" 直接传递密码
    # IMPORTANT: openssl enc output includes Salted__ header and base64.
    # Using "-a" for base64 encoding.
    # hash -r # Force shell to re-find openssl
    encrypted_string=$(printf "%s" "$mnemonic" | /data/data/com.termux/files/usr/bin/openssl enc $OPENSSL_OPTS -pass pass:"$password_input")

    local openssl_exit_code=$?

    if [[ $openssl_exit_code -ne 0 ]] || [[ -z "$encrypted_string" ]]; then
        echo "错误：加密失败！" >&2
        echo "请检查 openssl 是否正常工作或密码是否有特殊字符导致问题。" >&2
        echo "OpenSSL 退出码: $openssl_exit_code" >&2
        cleanup_vars # 清理密码和助记词
        return 1
    fi

    echo "--------------------------------------------------"
    echo "✅ 助记词已生成并加密成功！"
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
    # 显式清除 password_input (虽然 cleanup_vars 应该包含了它)
    unset password_input
}

# 选项 2: 解密并显示
decrypt_and_display() {
    echo "--------------------------------------------------"
    echo "⚠️ 警告：强烈建议在断开网络连接（例如开启飞行模式）的情况下执行此操作！"
    echo "--------------------------------------------------"
    read -p "按 Enter 键继续，或按 Ctrl+C 取消..."

    local encrypted_string_input
    echo "请粘贴之前保存的【加密字符串】:"
    # 使用 read -r 防止反斜杠被解释，使用 -p "" 避免自动换行提示
    read -r encrypted_string_input
    if [[ -z "$encrypted_string_input" ]]; then
        echo "错误：未输入加密字符串。" >&2
        cleanup_vars
        return 1
    fi

    local password_input
    echo "请输入解密密码。"
    password_input=$(get_password "输入解密密码")
     if [[ -z "$password_input" ]]; then
         echo "错误: 未能获取有效密码。" >&2
         cleanup_vars
         return 1
    fi

    echo "正在尝试解密..."
    local decrypted_mnemonic
    # 使用 heredoc 传递加密字符串给 openssl stdin
    # 使用 2> /dev/null 隐藏 openssl 的错误信息 (如 bad decrypt)
    # openssl base64 decode (-d -a) is part of the decryption process when using -a flag
    # Need to pipe the input string to openssl
    # hash -r # Force shell to re-find openssl
    decrypted_mnemonic=$(printf "%s" "$encrypted_string_input" | /data/data/com.termux/files/usr/bin/openssl enc -d $OPENSSL_OPTS -pass pass:"$password_input" 2> /dev/null)

    local openssl_exit_code=$?

    # 检查 openssl 的退出状态码
    if [[ $openssl_exit_code -ne 0 ]]; then
        echo "--------------------------------------------------"
        echo "❌ 错误：解密失败！" >&2
        echo "   - 请仔细检查您输入的【加密字符串】是否完整且无误（包括开头和结尾）。" >&2
        echo "   - 请确认您输入的【解密密码】是否完全正确。" >&2
        echo "   (OpenSSL 退出码: $openssl_exit_code)" >&2
        echo "--------------------------------------------------"
        cleanup_vars # 清理密码和输入的字符串
        return 1
    fi

     # 额外检查解密结果是否为空或格式异常
     # Simple check: BIP39 24 words should contain 23 spaces
     local word_count=$(echo "$decrypted_mnemonic" | wc -w)
     if [[ -z "$decrypted_mnemonic" ]] || [[ "$word_count" -ne 24 ]]; then
         echo "--------------------------------------------------"
         echo "❌ 错误：解密结果无效！" >&2
         echo "   解密成功，但结果看起来不像有效的 24 位助记词（单词数不正确）。" >&2
         echo "   这可能表示解密过程异常，或者原始加密字符串已被损坏。" >&2
         echo "   请检查原始加密字符串和密码。" >&2
         echo "--------------------------------------------------"
         cleanup_vars
         return 1
     fi


    echo "--------------------------------------------------"
    echo "✅ 解密成功！您的 BIP39 助记词是:"
    echo ""
    echo "$decrypted_mnemonic"
    echo ""
    echo "--------------------------------------------------"
    echo "⚠️ 重要提示："
    echo "   1. **立即安全地记录** 上述助记词原文！确保周围无人窥视。"
    echo "   2. 最好将其抄写在物理介质上，并存放在安全的地方。"
    echo "   3. 确认记录无误后，**强烈建议清除终端屏幕和历史记录**！"
    echo "      - 清屏: 输入 'clear' 命令。"
    echo "      - 清除历史记录: 输入 'history -c && history -w' (或直接退出 Termux 会话)。"
    echo "--------------------------------------------------"

    # 操作完成后清理敏感变量
    cleanup_vars
    # 显式清除 password_input (虽然 cleanup_vars 应该包含了它)
    unset password_input
}

# --- 脚本入口 ---

# 首先创建临时的 Python 脚本文件并设置清理 trap
create_python_script_temp_file

# 然后检查并安装依赖
install_dependencies

# 主菜单循环
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
            generate_and_encrypt
            ;;
        2)
            decrypt_and_display
            ;;
        q | Q)
            echo "正在退出..."
            # Trap will handle cleanup
            exit 0
            ;;
        *)
            echo "无效选项 '$choice'，请重新输入。"
            ;;
    esac
    # 在每次操作后暂停，等待用户确认，防止信息快速滚动消失
    echo "" # 在提示前加一行空行，美观一些
    read -n 1 -s -r -p "按任意键返回主菜单..."
    echo # 换行
done

# The trap set by create_python_script_temp_file handles cleanup on exit.
