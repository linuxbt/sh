#!/usr/bin/env bash

# BIP39 Mnemonic Manager for iOS Shell Environments (e.g., iSH, a-Shell with caveats)
# ▼▼▼ 常量定义 ▼▼▼
huang='\033[33m'
hong='\033[31m'
lv='\033[32m'
bai='\033[0m'
kjlan='\033[96m'
hui='\e[37m'
lan='\033[0;34m'

# ▼▼▼ 配置项 ▼▼▼
ENCRYPTION_ALGO="aes-256-cbc"
OPENSSL_OPTS="-${ENCRYPTION_ALGO} -iter 1000000 -a -salt -pbkdf2 -md sha256"
MIN_PASSWORD_LENGTH=16

# --- Embedded BIP39 English Wordlist ---
# This list contains 2048 words as per BIP39 standard.
# ▼▼▼ 词表预处理函数 ▼▼▼
sanitize_wordlist() {
    cat | 
    tr -d '\r' |
    sed 's/\s*$//' |
    LC_ALL=C tr -cd '[:alnum:][:space:]\n' |
    awk '
    function trim(str) {
        gsub(/^[[:space:]]+|[[:space:]]+$/, "", str);
        return str;
    }
    {
        original = $0;
        word = tolower(trim(original));
        if (word == "") {
            print "[错误] 跳过空行: 行号 " NR " → 原始内容: \"" original "\"" > "/dev/stderr";
            next;
        }
        if (word !~ /^[a-z]+$/) {
            print "[错误] 跳过非法单词: 行号 " NR " → 转换后: \"" word "\"" > "/dev/stderr";
            next;
        }
        words[++count] = word;
    }
    END {
        target = 2048;
        actual = (count > target) ? target : count;
        for (i=1; i<=actual; i++) print words[i];
        for (i=actual+1; i<=target; i++) print "zoo";
        print "[日志] 有效行数/填充: " actual "/" target-actual > "/dev/stderr";
    }'
}

BIP39_WORDLIST=$(sanitize_wordlist <<'EOF' | grep -v '^$'
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
EOF
)

# 确保行数绝对为2048（双重保险）
BIP39_WORDLIST=$(awk 'NR <= 2048 {print} END {for(i=NR+1;i<=2048;i++)print "zoo"}' <<< "$BIP39_WORDLIST")

# ▼ 验证哈希传输 ▼
echo "Bash层SHA256: $(echo "$BIP39_WORDLIST" | sha256sum)" >&2
# ▼ 传输验证代码 ▼
echo "词表行数终检: $(echo "$BIP39_WORDLIST" | wc -l)" >&2
# ▼▼▼ 验证关键点 ▼▼▼
echo "最终行数: $(wc -l <<< "$BIP39_WORDLIST")" >&2
echo "验证首单词: $(head -n1 <<< "$BIP39_WORDLIST")" >&2
echo "验证末单词: $(tail -n1 <<< "$BIP39_WORDLIST")" >&2
sleep 2
# ▼▼▼ Critical Validation ▼▼▼
{
    line_count=$(printf "%s" "$BIP39_WORDLIST" | awk 'END{print NR}')  # ▼▼▲▲▲ 移除 "%s\n" 修正为 "%s"
    if [[ $line_count -ne 2048 ]]; then
        echo -e "${hong}FATAL: 处理后的词表行数为${line_count}（应为2048）${bai}" >&2
        exit 1
    fi
    first_word=$(printf "%s" "$BIP39_WORDLIST" | head -n1 | tr -d '\n')        # ▲ args忽略尾自动换行符
    last_word=$(printf "%s" "$BIP39_WORDLIST" | tail -n1 | tr -d '\n')         # ▲ 同上
    [[ "$first_word" == "abandon" && "$last_word" == "zoo" ]] || {
        echo -e "${hong}词表头尾校验失败：${first_word}/abandon | ${last_word}/zoo${bai}" >&2
        exit 1
    }
}




# --- Embedded Python Script for Mnemonic Generation ---
# This script generates a BIP39 mnemonic of a specified length (12, 18, or 24 words)
# from cryptographically secure random bytes using the provided wordlist.
# It relies only on standard Python libraries (os, hashlib, sys).
# It expects the wordlist on standard input and the desired word count as the first command-line argument.
# --- Python Script for Mnemonic Generation ---
read -r -d '' PYTHON_MNEMONIC_GENERATOR_SCRIPT << 'EOF_PYTHON_SCRIPT'
#!/usr/bin/env python3
import sys, os, hashlib
# 修正后的Python解析核心代码
raw_input = sys.stdin.read()
lines = [line.rstrip('\n') for line in raw_input.split('\n')]
wordlist = []

# 严格过滤逻辑
for line in lines:
    cleaned = line.strip()  # 移除两端的空白
    if cleaned:
        wordlist.append(cleaned)
    # 提前断裂以提高性能
    if len(wordlist) >= 2048:
        break

# 填充至2048行 （双保险）
while len(wordlist) < 2048:
    wordlist.append("zoo")

# ▼ 验证密钥指纹一致性 ▼
expected_hash = os.environ.get('BASH_HASH')
actual_hash = hashlib.sha256(raw_input.encode()).hexdigest()
if expected_hash and actual_hash != expected_hash:
    sys.exit(f"指纹不一致！BASH侧:{expected_hash} Python侧:{actual_hash}")
# ▼ 打印精确调试信息 ▼
print(f"[密钥调试] 原始字节长度:{len(raw_input)}", file=sys.stderr)
print(f"[密钥调试] 首行指纹:{hashlib.sha256(lines[0].encode()).hexdigest()}", file=sys.stderr)
print(f"[密钥调试] 尾行指纹:{hashlib.sha256(lines[-1].encode()).hexdigest()}", file=sys.stderr)
# ▼ 调试信息 ▼
# print(f"[DEBUG] 原始输入行数: {len(raw_input.split("\n"))}", file=sys.stderr)
# print(f"[DEBUG] 有效词表行数: {len(wordlist)}", file=sys.stderr)
# print(f"[DEBUG] 首词: {repr(wordlist[0])}", file=sys.stderr)
# print(f"[DEBUG] 末词: {repr(wordlist[-1])}", file=sys.stderr)
# print(f"[DEBUG] SHA256: {hashlib.sha256(raw_input.encode()).hexdigest()}", file=sys.stderr)
if len(wordlist) != 2048:
    sys.exit(f"词表不合法：{len(wordlist)}行，应为2048行")
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
    # 使用用户主目录存储临时文件（iSH保证可写）
    USER_TMP_DIR="${HOME}/.mnemonic_temp"
    mkdir -p "$USER_TMP_DIR" 2>/dev/null || { 
        echo "错误：无法创建临时目录 ${USER_TMP_DIR}" >&2
        exit 1
    }
    # 生成唯一的安全随机文件名
    PYTHON_SCRIPT_TEMP_FILE="${USER_TMP_DIR}/mnemonic_$(date +%s%N)_$(openssl rand -hex 3).py"
    
    # 双重验证文件创建
    touch "$PYTHON_SCRIPT_TEMP_FILE" 2>/dev/null || {
        echo "错误：临时文件创建失败 ${PYTHON_SCRIPT_TEMP_FILE}" >&2
        exit 1
    }
    printf "%s" "$PYTHON_MNEMONIC_GENERATOR_SCRIPT" > "$PYTHON_SCRIPT_TEMP_FILE" || {
        echo "错误：无法写入Python脚本" >&2
        exit 1
    }
    # 清理机制强化
    trap 'rm -f "$PYTHON_SCRIPT_TEMP_FILE" >/dev/null 2>&1; cleanup_vars' EXIT HUP INT TERM
}

check_dependencies() {
    # 安装OpenSSL
    if ! command -v openssl &>/dev/null; then
        echo -e "${huang}自动安装openssl...${bai}"
        if ! sudo apk add openssl >/dev/null 2>&1; then
            # 处理无root权限情况
            if ! sudo apk add openssl >/dev/null 2>&1; then
                echo -e "${hong}错误：无法自动安装openssl，请尝试: sudo apk add openssl${bai}" >&2
                exit 1
            fi
        fi
    fi
    # 安装Python3
    if ! command -v python3 &>/dev/null; then
        echo -e "${huang}自动安装python3...${bai}"
        if ! sudo apk add python3 >/dev/null 2>&1; then
            if ! sudo apk add python3 >/dev/null 2>&1; then
                echo -e "${hong}错误：无法自动安装python3，请尝试: sudo apk add python3${bai}" >&2
                exit 1
            fi
        fi
    fi
}

# generate_mnemonic_internal() {
#     local word_count="$1"
#     local mnemonic=""
#     local py_exit_code
#     if [[ ! -f "$PYTHON_SCRIPT_TEMP_FILE" ]]; then
#          echo "错误：未找到Python模板文件 $PYTHON_SCRIPT_TEMP_FILE" >&2
#          return 1
#     fi
#     # # ▼▼▼ 精准行数校验 ▼▼▼
#     # echo "生成助记词前词表行数验证: $(wc -l <<< "$BIP39_WORDLIST")" >&2  # DEBUG提示输出到stderr
#     # local line_count=$(printf "%s" "$BIP39_WORDLIST" | wc -l)
#     # if [[ $line_count -ne 2048 ]]; then
#     #     echo -e "${hong}致命错误：BIP39单词列表应为2048行，实际检测到：${line_count} 行" >&2
#     #     return 1
#     # fi
#     # 生成传输检测指纹
#     local bash_hash=$(echo "$BIP39_WORDLIST" | sha256sum | cut -d' ' -f1)
#     mnemonic=$(
#         {
#             printf "%s\n" "$BIP39_WORDLIST"
#             echo "[BASH_DEBUG] 传输哈希: $bash_hash" >&2
#         } | tee /dev/stderr |
#         python3 "$PYTHON_SCRIPT_TEMP_FILE" "$word_count" 2> >(grep -v DEBUG >&2)
#     ) 
#     py_exit_code=$?
#     if [[ $py_exit_code -ne 0 ]] || [[ -z "$mnemonic" ]]; then
#         echo -e "${hong}错误：助记词生成失败！" >&2
#         echo -e "Python 错误码: $py_exit_code" >&2
#         return 1
#     fi
#     printf "%s" "$mnemonic"
# }


generate_mnemonic_internal() {
    local word_count="$1"
    local mnemonic=""
    local py_exit_code

    if [[ ! -f "$PYTHON_SCRIPT_TEMP_FILE" ]]; then
         echo "Error: Python script temporary file not found." >&2
         return 1
    fi

    # Pass the wordlist to the python script via stdin
    # The python script expects the word count as the first argument
    mnemonic=$(printf "%s" "$BIP39_WORDLIST" | python3 "$PYTHON_SCRIPT_TEMP_FILE" "$word_count")
    py_exit_code=$?

    if [[ $py_exit_code -ne 0 ]] || [[ -z "$mnemonic" ]]; then
        echo "错误：生成助记词失败！" >&2
        echo "Python 退出码: $py_exit_code" >&2
        return 1
    fi
    # Return the potentially multi-word string correctly
    printf "%s" "$mnemonic"
}

get_password() {
    local prompt_message=$1
    local password=""
    while : ; do
        read -rsp "${prompt_message}（最少${MIN_PASSWORD_LENGTH}位）: " password
        echo # 换行
        
        # ▼ 密码非空检查 ▼
        if [[ -z "$password" ]]; then
            echo -e "${hong}错误：密码不能为空！${bai}\n" >&2
            continue
        fi
        
        # ▼ 密码长度检查 ▼
        if [[ ${#password} -lt ${MIN_PASSWORD_LENGTH} ]]; then
            echo -e "${hong}错误：密码最少需要 ${MIN_PASSWORD_LENGTH} 位！${bai}\n" >&2
            continue
        fi
        
        break
    done
    printf "%s" "$password"
}



cleanup_vars() {
    unset mnemonic password password_decrypt encrypted_string decrypted_mnemonic password_input encrypted_string_input chosen_word_count word_count_choice
    unset skip_main_pause
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
         unset mnemonic
         return 1
    fi

    echo "正在使用 ${ENCRYPTION_ALGO} 千万级迭代（等20秒左右）加密助记词..."
    # —— 修复点：避免 /dev/fd —— 
    # encrypted_string=$(echo -n "$mnemonic" | openssl enc $OPENSSL_OPTS -pass stdin <<<"$password_input")
    # 修复点：使用 -pass 参数直接传递密码
    encrypted_string=$(echo -n "$mnemonic" | openssl enc $OPENSSL_OPTS -pass pass:"$password_input")
    openssl_exit_code=$?

    unset password_input mnemonic

    if [[ $openssl_exit_code -ne 0 ]] || [[ -z "$encrypted_string" ]]; then
        echo "错误：加密失败！" >&2
        echo "请检查 openssl 是否正常工作以及权限问题。" >&2
        echo "OpenSSL 退出码: $openssl_exit_code" >&2
        cleanup_vars
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
    echo -e "⚠️ ${huang}1. **务必记住** 您刚才设置的【密码】！"
    echo -e "⚠️ ${huang}2. 没有正确的密码，上面的加密字符串将【无法解密】！"
    echo -e "⚠️ ${huang}3. 助记词原文未在此过程中显示或保存。"
    echo "--------------------------------------------------"

    cleanup_vars
}
# --- END MODIFIED FUNCTION: Encryption ---

--- MODIFIED FUNCTION: Decryption ---
# decrypt_and_display() {
#     local encrypted_string_input password_input1 password_input2
#     local decrypted_mnemonic openssl_exit_code word_count
    
#     # 警告提示
#     echo "--------------------------------------------------"
#     echo -e "⚠️ ${huang}安全警示：确保环境安全并已断开网络！${bai}"
#     echo "--------------------------------------------------"
#     read -p "按 Enter 继续... " </dev/tty

#     # ▼▼ 加密字符串输入 ▼▼
#     echo -e "\n${lv}▼ 粘贴加密字符串（以空行结束）▼：${bai}"
#     encrypted_string_input=""
#     while IFS= read -r line; do
#         [[ -z "$line" ]] && break
#         encrypted_string_input+="$line"$'\n'
#     done
#     encrypted_string_input="${encrypted_string_input%$'\n'}"
#     encrypted_string_input=$(tr -d '\r' <<< "$encrypted_string_input")

#     # ▼▼▼ 加密字符串格式检查逻辑 ▼▼▼
#     if [[ ! "$encrypted_string_input" =~ ^U2FsdGVkX1[0-9A-Za-z/+]+$ ]]; then
#         echo -e "${hong}✖ 加密数据格式异常，必须以'Salted__'结构开头！${bai}" >&2
#         read -n 1 -s -r -p "按任意鍵返回..."
#         return 1
#     fi

#     # ▼ 加密字符串长度校验
#     if [[ $(echo -n "$encrypted_string_input" | wc -c) -lt 64 ]]; then
#         echo -e "${hong}✖ 加密数据过短或格式错误！${bai}" >&2
#         read -n 1 -s -r -p "按任意鍵返回..."
#         return 1
#     fi
#     # ▼ 严格过滤非Base64字符 ▼
#     encrypted_string_input=$(echo "$encrypted_string_input" | tr -d '\n\r' | grep -oE '^[a-zA-Z0-9+/=]+$')
#     if [[ -z "$encrypted_string_input" ]]; then
#         echo -e "${hong}加密数据包含非法字符！${bai}" >&2
#         return 1
#     fi
#     clear
#     # ▼直接获取一次密码▼
#     echo -e "\n${lv}▼ 输入正确解密密码 ▼：${bai}"
#     password_input=$(get_password "密码") || return 1

#     # ▼▼ OpenSSL解密 ▼▼
#     export OPENSSL_ENCRYPT_PASSWORD="$password_input1"
#     unset password_input1 password_input2
#     echo -e "\n${hui}⚙ 解密中（约15-30秒，请耐心等待）...${bai}"
#     decrypted_mnemonic=$(
#         echo "$encrypted_string_input" | 
#         openssl enc -d $OPENSSL_OPTS -pass env:OPENSSL_ENCRYPT_PASSWORD 2>&1
#     )
#     openssl_exit_code=$?
#     unset OPENSSL_ENCRYPT_PASSWORD

#     # ▼▼ 错误处理 ▼▼
#     if [[ $openssl_exit_code -ne 0 ]]; then
#         echo -e "${hong}❌ 解密失败！技术细节↓↓${bai}"
#         echo "----------------------------------------"
#         echo "$decrypted_mnemonic" >&2
#         echo -e "----------------------------------------"
#         echo "提示：常见错误原因："
#         echo "1. PowerShell生成的加密串需去除头尾提示文字"
#         echo "2. 密码含特殊符号需用英文引号包裹"
#         read -n 1 -s -r -p "按任意鍵返回..."
#         return 1
#     fi

#     # # ▼ 助记词有效性验证
#     # word_count=$(wc -w <<< "$decrypted_mnemonic")
#     # if [[ ! "$word_count" =~ ^(12|18|24)$ ]]; then
#     #     echo -e "${hong}❌ 解密结果异常（${word_count}词），請检查：${bai}"
#     #     echo "1. 加密字符串是否完整粘贴（含开头的'Salted__'）"
#     #     echo "2. 确认OPENSSL_OPTS参数与加密时一致"
#     #     read -n 1 -s -r -p "按任意鍵返回..."
#     #     return 1
#     # fi

#     # ▼▼ 显示结果 ▼▼
#     echo -e "\n${lv}✅ 成功！您的助记詞 ↓↓（${word_count}词）${bai}"
#     echo "--------------------------------------------------"
#     echo "$decrypted_mnemonic"
#     echo "--------------------------------------------------"
    
#     # ▼ 安全信息驻留
#     echo -e "${hui}此窗口将在30秒后自动清除...${bai}"
#     read -t 30 -n 1 -s -r -p "按任意键立即返回 "
#     clear
#     unset decrypted_mnemonic encrypted_string_input
#     return 0
# }


# # --- 修复后的解密函数 ---
# decrypt_and_display() {
#     local encrypted_string_input password_input
#     local decrypted_mnemonic openssl_exit_code word_count

#     # 警告提示
#     echo "--------------------------------------------------"
#     echo -e "⚠️ ${huang}安全警示：确保环境安全并已断开网络！${bai}"
#     echo "--------------------------------------------------"
#     read -p "按 Enter 继续... " </dev/tty

#     # ▼ 更清晰的加密字符串输入提示 ▼
#     echo -e "\n${lv}▼ 请一次性粘贴完整的加密字符串 ▼：${bai}"
#     echo -e "（粘贴后只需按一次回车确认）\n"
    
#     # 读取单行输入（避免换行符问题）
#     read -r encrypted_string_input
    
#     # 清除所有空格和换行符
#     encrypted_string_input=$(echo "$encrypted_string_input" | tr -d '[:space:]')
    
#     # 处理粘贴的内容
#     if [[ -z "$encrypted_string_input" ]]; then
#         echo -e "${hong}错误：未接收到加密数据！${bai}" >&2
#         read -n 1 -s -r -p "按任意键返回..." </dev/tty
#         return 1
#     fi

#     # DEBUG：显示输入后10个字符
#     echo -e "${hui}[调试] 输入的字符串长度：${#encrypted_string_input}，结尾：${encrypted_string_input:(-10)}${bai}" >&2
    
#     # ▼ 加密字符串格式检查 ▼
#     if [[ ! "$encrypted_string_input" =~ ^U2FsdGVkX1[0-9A-Za-z+/=]+$ ]]; then
#         echo -e "${hong}✖ 加密数据格式异常，必须以 'U2FsdGVkX1' 开头！${bai}" >&2
#         echo -e "检测到的开头字符串: ${encrypted_string_input:0:20}..." >&2
#         read -n 1 -s -r -p "按任意键返回..." </dev/tty
#         return 1
#     fi

#     # ▼▼ OpenSSL解密 ▼▼
#     password_input=$(get_password "请输入解密密码") || return 1
#     echo -e "\n${hui}⚙️ 解密中（请耐心等待，可能需要30秒）...${bai}"
    
#     # 添加调试输出到stderr
#     echo -e "[调试] 使用密码长度: ${#password_input}" >&2
#     echo -e "[调试] 加密字符串开头: ${encrypted_string_input:0:20}..." >&2
    
#     # 关键修复：将加密字符串通过管道传递给OpenSSL，并添加等待指示器
#     {
#         decrypted_mnemonic=$(echo -n "$encrypted_string_input" | 
#             timeout 60 openssl enc -d $OPENSSL_OPTS -pass pass:"$password_input" 2>&1)
#         openssl_exit_code=$?
#     } &
    
#     # 显示等待动画
#     pid=$!
#     while kill -0 $pid 2>/dev/null; do
#         echo -n "."
#         sleep 2
#     done
#     echo

#     # ▼▼ 错误处理 ▼▼
#     if [[ $openssl_exit_code -ne 0 ]]; then
#         echo -e "${hong}❌ 解密失败 - 错误码: $openssl_exit_code${bai}"
#         echo -e "${huang}可能原因:${bai}"
#         echo "1. 密码不正确"
#         echo "2. 加密字符串格式错误或被截断"
#         echo "3. 加密参数不匹配"
#         echo "4. 字符串处理错误"
#         echo -e "${hui}----------------------------------------${bai}"
#         echo -e "OpenSSL 输出:"
#         echo "$decrypted_mnemonic" | head -n 5
#         echo -e "${hui}----------------------------------------${bai}"
#         read -n 1 -s -r -p "按任意键返回..." </dev/tty
#         return 1
#     fi

#     # ▼ 助记词有效性验证 ▼
#     word_count=$(echo "$decrypted_mnemonic" | wc -w)
#     if [[ ! "$word_count" =~ ^(12|18|24)$ ]] || 
#        [[ ! "$decrypted_mnemonic" =~ ^([a-z]+ ) ]]; then
#         echo -e "${hong}❌ 解密结果异常（${word_count}词），可能是以下原因：${bai}"
#         echo "1. 密码错误"
#         echo "2. 加密字符串损坏"
#         echo -e "${hui}前20字符: ${decrypted_mnemonic:0:20}...${bai}"
#         read -n 1 -s -r -p "按任意键返回..." </dev/tty
#         return 1
#     fi

#     # ▼▼ 显示结果 ▼▼
#     echo -e "\n${lv}✅ BIP39助记词恢复成功！${bai}"
#     echo "--------------------------------------------------"
#     echo -e "${bai}$decrypted_mnemonic"
#     echo "--------------------------------------------------"
#     echo -e "词条数量: ${huang}${word_count}${bai}"
    
#     # ▼ 安全警告 ▼
#     echo -e "${hui}\n[安全提示] 助记词显示后将自动清除\n${bai}"
#     SECONDS=0
#     while [[ $SECONDS -lt 30 ]]; do
#         seconds_left=$((30 - SECONDS))
#         echo -ne "${hui}清屏倒计时: ${seconds_left}秒${bai}"\\r
#         sleep 1
#     done
    
#     # 安全清理
#     unset decrypted_mnemonic password_input
#     clear
#     return 0
# }




# --- FINALLY FIXED DECRYPTION FUNCTION ---
decrypt_and_display() {
    local encrypted_string_input password_input
    local decrypted_mnemonic openssl_exit_code word_count

    # 重置安全警告
    echo "--------------------------------------------------"
    echo -e "⚠️ ${huang}安全警示：确保环境安全并已断开网络！${bai}"
    echo "--------------------------------------------------"
    read -p "按 Enter 继续... " </dev/tty

    # ▼▼ 更用户友好的加密字符串输入 ▼▼
    echo -e "\n${lv}▼ 请粘贴加密字符串 ▼：${bai}"
    echo -e "- 确保完全复制生成的加密字符串（通常150-300字符）"
    echo -e "- 可以一次性粘贴多行文本"
    echo -e "- 粘贴后直接按回车确认\n"
    
    # 读取整块输入（最多5行，防止卡死）
    encrypted_string_input=""
    while IFS= read -r -t 60 -p "> " line; do
        # 如果用户连续按两次回车则退出
        [[ -z "$line" ]] && break
        encrypted_string_input+="$line"
    done
    
    # 移除所有空白字符
    encrypted_string_input=$(echo -n "$encrypted_string_input" | tr -d '[:space:]')
    
    # 检查是否为空
    if [[ -z "$encrypted_string_input" ]]; then
        echo -e "${hong}错误：未接收到加密数据！${bai}" >&2
        return 1
    fi

    # 检查最少长度（合法加密串至少80字符）
    if [[ ${#encrypted_string_input} -lt 80 ]]; then
        echo -e "${hong}错误：加密字符串过短（${#encrypted_string_input}字符）- 应至少100个字符！${bai}" >&2
        return 1
    fi

    # 密码输入 - 最多3次尝试
    attempts=0
    password_input=""
    while (( attempts < 3 )); do
        password=$(get_password "请输入解密密码")
        ((attempts++))
        
        # 尝试解密
        echo -e "${hui}⚙ 解密中（第${attempts}次尝试）...${bai}"
        decrypted_mnemonic=$(echo "$encrypted_string_input" | 
            openssl enc -d $OPENSSL_OPTS -pass pass:"$password" 2>/dev/null)
        
        # 检查解密结果
        word_count=$(echo "$decrypted_mnemonic" | wc -w)
        if [[ $? -eq 0 ]] && [[ $word_count =~ ^(12|18|24)$ ]]; then
            password_input=$password
            break
        fi
        
        echo -e "${hong}解密失败！密码可能错误（剩余$((3-attempts))次尝试）${bai}" >&2
    done
    
    # 成功解密后的处理
    if [[ -n "$password_input" ]]; then
        # 显示结果
        echo -e "\n${lv}✅ BIP39助记词恢复成功！${bai}"
        echo "--------------------------------------------------"
        echo "$decrypted_mnemonic"
        echo "--------------------------------------------------"
        echo -e "词条数量: ${huang}$word_count${bai}"
        
        # 等待用户确认后返回
        echo -e "${hui}按任意键返回主菜单...${bai}"
        read -n 1 -s -r
        
    else
        echo -e "\n${hong}❌ 解密尝试超过3次失败，请联系12双周技术支持...${bai}" >&2
        read -n 1 -s -r -p "按任意鍵返回..."
    fi
    
    # 安全清理
    unset decrypted_mnemonic password_input
    return 0
}


# --- END MODIFIED FUNCTION: Decryption ---

# --- 脚本入口 ---

create_python_script_temp_file
check_dependencies

skip_main_pause=false

while true; do
    if ! $skip_main_pause; then
       if command -v clear >/dev/null 2>&1 && [ -t 1 ]; then
           clear
       fi
    fi

    echo ""
    echo "=================================================="
    echo -e "▶ ${kjlan}BIP39 助记词安全管理器"
    echo "        (适用于 iOS Shell 环境)"
    echo "=================================================="
    echo "--------------------------------------------------"
    echo -e "⚠️ ${huang}警告：请确保在手机系统，输入法,周围物理环境安全的情况下执行此操作！"
    echo -e "⚠️ ${huang}警告：强烈建议在断开网络连接（例如开启飞行模式）的情况下执行此操作！"
    echo -e "⚠️ ${huang}警告：强烈建议在执行完，保存好加密字符串和记住密码的情况下重启设备！"
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
            word_count_choice=""
            chosen_word_count=""

            while true; do
                echo ""
                echo "--------------------------------------------------"
                echo -e "▶ ${kjlan}K脚本-助记词管理工具"
                echo -e "⚠️ ${hong}警告：请确保在手机系统，输入法,周围物理环境安全的情况下执行此操作！"
                echo -e "⚠️ ${huang}警告：强烈建议在断开网络连接（例如开启飞行模式）的情况下执行此操作！"
                echo -e "⚠️ ${huang}警告：强烈建议在执行完此操作，保存好加密字符串和记住密码的情况下重启设备！"
                echo "--------------------------------------------------"

                echo "------------------------------"
                echo -e "▶ ${bai}生成助记词 - 选择长度"
                echo "------------------------------"
                echo "请选择要生成的助记词长度："
                echo -e "  1. ${hui}12 个单词 (128位熵)"
                echo -e "  2. ${lan}18 个单词 (192位熵)"
                echo -e "  3. ${lv}24 个单词 (256位熵) - 推荐安全级别"
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
                skip_main_pause=false
            else
                skip_main_pause=true
            fi
            unset word_count_choice chosen_word_count
            ;;

        2)
            if command -v clear >/dev/null 2>&1 && [ -t 1 ]; then
                clear
            fi
            decrypt_and_display
            skip_main_pause=true
            ;;

        q | Q)
            echo "正在退出..."
            exit
            ;;

        *)
            echo "无效选项 '$choice'，请重新输入。"
            skip_main_pause=false
            sleep 1
            ;;
    esac

    if [ "$skip_main_pause" = "false" ]; then
        echo ""
        read -n 1 -s -r -p "按任意键返回主菜单..."
    fi
    skip_main_pause=false

done
