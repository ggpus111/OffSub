package com.example.offsub

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.animation.*
import androidx.compose.animation.core.*
import androidx.compose.foundation.*
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material.icons.outlined.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.shadow
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import kotlinx.coroutines.launch

// ─────────────────────────────────────────────
//  Colors
// ─────────────────────────────────────────────
val LightBlue50  = Color(0xFFE3F2FD)
val LightBlue100 = Color(0xFFBBDEFB)
val LightBlue200 = Color(0xFF90CAF9)
val Purple400    = Color(0xFF7E57C2)
val Purple300    = Color(0xFF9575CD)
val Purple100    = Color(0xFFD1C4E9)
val SurfaceWhite = Color(0xFFFAFAFF)
val CardWhite    = Color(0xFFFFFFFF)
val TextPrimary  = Color(0xFF1A1A2E)
val TextSecondary= Color(0xFF6B7280)
val GreenOk      = Color(0xFF4CAF50)
val OrangeWarn   = Color(0xFFFFA726)
val RedBad       = Color(0xFFEF5350)

// ─────────────────────────────────────────────
//  Data model
// ─────────────────────────────────────────────
enum class ValueGrade(val label: String, val color: Color) {
HIGH("상", GreenOk),
MID ("중", OrangeWarn),
LOW ("하", RedBad)
}

data class Subscription(
val id: Int,
val name: String,
val icon: ImageVector,
val monthlyFee: Int,        // KRW
val usageHoursPerMonth: Int,
val grade: ValueGrade,
val category: String,
var isActive: Boolean = true
)

val sampleSubscriptions = listOf(
Subscription(1, "Netflix",    Icons.Filled.PlayCircle,      17000, 42, ValueGrade.HIGH, "영상"),
Subscription(2, "Spotify",   Icons.Filled.MusicNote,        10900,  8, ValueGrade.MID,  "음악"),
Subscription(3, "YouTube",   Icons.Filled.OndemandVideo,   14900, 60, ValueGrade.HIGH, "영상"),
Subscription(4, "Watcha",    Icons.Filled.Movie,            12900,  3, ValueGrade.LOW,  "영상"),
Subscription(5, "Adobe CC",  Icons.Filled.Brush,           62000, 20, ValueGrade.MID,  "도구"),
Subscription(6, "Coupang",   Icons.Filled.ShoppingBag,      7890, 15, ValueGrade.HIGH, "쇼핑"),
)

// ─────────────────────────────────────────────
//  MainActivity
// ─────────────────────────────────────────────
class MainActivity : ComponentActivity() {
override fun onCreate(savedInstanceState: Bundle?) {
super.onCreate(savedInstanceState)
enableEdgeToEdge()
setContent {
OffSubTheme {
OffSubApp()
}
}
}
}

// ─────────────────────────────────────────────
//  Theme
// ─────────────────────────────────────────────
@Composable
fun OffSubTheme(content: @Composable () -> Unit) {
val colorScheme = lightColorScheme(
primary        = Purple400,
onPrimary      = Color.White,
primaryContainer   = Purple100,
secondary      = LightBlue200,
background     = SurfaceWhite,
surface        = CardWhite,
surfaceVariant = LightBlue50,
onBackground   = TextPrimary,
onSurface      = TextPrimary,
)
MaterialTheme(colorScheme = colorScheme, content = content)
}

// ─────────────────────────────────────────────
//  Root App
// ─────────────────────────────────────────────
@Composable
fun OffSubApp() {
var selectedTab by remember { mutableIntStateOf(0) }
var subscriptions by remember { mutableStateOf(sampleSubscriptions) }

// Bottom sheet state
val sheetState = rememberModalBottomSheetState(skipPartiallyExpanded = true)
val scope = rememberCoroutineScope()
var pendingOffSub by remember { mutableStateOf<Subscription?>(null) }

// Show cancellation guide sheet
if (pendingOffSub != null) {
CancellationGuideSheet(
subscription = pendingOffSub!!,
sheetState   = sheetState,
onConfirm    = {
subscriptions = subscriptions.map {
if (it.id == pendingOffSub!!.id) it.copy(isActive = false) else it
}
pendingOffSub = null
},
onDismiss    = { pendingOffSub = null }
)
}

Scaffold(
containerColor = SurfaceWhite,
bottomBar = {
OffSubBottomBar(
selectedTab    = selectedTab,
onTabSelected  = { selectedTab = it }
)
}
) { innerPadding ->
Box(modifier = Modifier.padding(innerPadding)) {
when (selectedTab) {
0 -> HomeScreen(subscriptions)
1 -> SubscriptionListScreen(
subscriptions = subscriptions,
onToggle      = { sub, newState ->
if (!newState) {
// Propose cancellation guide
scope.launch {
pendingOffSub = sub
sheetState.show()
}
} else {
subscriptions = subscriptions.map {
if (it.id == sub.id) it.copy(isActive = true) else it
}
}
}
)
2 -> SettingsScreen()
}
}
}
}

// ─────────────────────────────────────────────
//  Bottom Navigation Bar
// ─────────────────────────────────────────────
@Composable
fun OffSubBottomBar(selectedTab: Int, onTabSelected: (Int) -> Unit) {
NavigationBar(
containerColor = CardWhite,
tonalElevation = 0.dp,
modifier = Modifier.shadow(8.dp)
) {
listOf(
Triple(Icons.Outlined.Home, Icons.Filled.Home, "홈"),
Triple(Icons.Outlined.CreditCard, Icons.Filled.CreditCard, "구독"),
Triple(Icons.Outlined.Settings, Icons.Filled.Settings, "설정")
).forEachIndexed { idx, (outline, filled, label) ->
NavigationBarItem(
selected  = selectedTab == idx,
onClick   = { onTabSelected(idx) },
icon      = {
Icon(
if (selectedTab == idx) filled else outline,
contentDescription = label
)
},
label     = { Text(label, fontSize = 11.sp) },
colors    = NavigationBarItemDefaults.colors(
selectedIconColor   = Purple400,
selectedTextColor   = Purple400,
indicatorColor      = Purple100,
unselectedIconColor = TextSecondary,
unselectedTextColor = TextSecondary
)
)
}
}
}

// ─────────────────────────────────────────────
//  1. Home Dashboard Screen
// ─────────────────────────────────────────────
@Composable
fun HomeScreen(subscriptions: List<Subscription>) {
val activeTotal   = subscriptions.filter { it.isActive  }.sumOf { it.monthlyFee }
val inactiveTotal = subscriptions.filter { !it.isActive }.sumOf { it.monthlyFee }
val savingsRate   = if (activeTotal + inactiveTotal > 0)
(inactiveTotal.toFloat() / (activeTotal + inactiveTotal) * 100).toInt() else 0

LazyColumn(
modifier            = Modifier.fillMaxSize(),
contentPadding      = PaddingValues(bottom = 24.dp),
verticalArrangement = Arrangement.spacedBy(0.dp)
) {
// Header gradient
item {
Box(
modifier = Modifier
    .fillMaxWidth()
    .background(
Brush.linearGradient(listOf(Purple400, Purple300, LightBlue200))
)
    .padding(top = 56.dp, bottom = 40.dp, start = 24.dp, end = 24.dp)
) {
Column {
Text(
"안녕하세요 👋",
color      = Color.White.copy(alpha = 0.85f),
fontSize   = 15.sp,
fontWeight = FontWeight.Normal
)
Spacer(Modifier.height(4.dp))
Text(
"이번 달 구독 현황",
color      = Color.White,
fontSize   = 26.sp,
fontWeight = FontWeight.Bold
)
}
}
}

// Summary cards
item {
Row(
modifier            = Modifier
    .fillMaxWidth()
    .padding(horizontal = 16.dp)
    .offset(y = (-28).dp),
horizontalArrangement = Arrangement.spacedBy(12.dp)
) {
SummaryCard(
modifier    = Modifier.weight(1f),
label       = "총 구독료",
value       = "₩${"%,d".format(activeTotal)}",
sub         = "활성 ${subscriptions.count { it.isActive }}개",
gradient    = listOf(Purple400, Purple300),
icon        = Icons.Filled.AccountBalanceWallet
)
SummaryCard(
modifier    = Modifier.weight(1f),
label       = "절약 가능",
value       = "₩${"%,d".format(inactiveTotal)}",
sub         = "비활성 ${subscriptions.count { !it.isActive }}개",
gradient    = listOf(LightBlue200, LightBlue100),
iconTint    = Purple400,
textColor   = TextPrimary,
subColor    = TextSecondary,
icon        = Icons.Filled.Savings
)
}
}

// Savings progress
item {
Card(
modifier      = Modifier.padding(horizontal = 16.dp).fillMaxWidth(),
shape         = RoundedCornerShape(20.dp),
colors        = CardDefaults.cardColors(containerColor = CardWhite),
elevation     = CardDefaults.cardElevation(4.dp)
) {
Column(modifier = Modifier.padding(20.dp)) {
Row(verticalAlignment = Alignment.CenterVertically) {
Icon(Icons.Filled.TrendingDown, null, tint = Purple400, modifier = Modifier.size(20.dp))
Spacer(Modifier.width(8.dp))
Text("절약률", fontWeight = FontWeight.SemiBold, fontSize = 15.sp, color = TextPrimary)
Spacer(Modifier.weight(1f))
Text("$savingsRate%", fontWeight = FontWeight.Bold, fontSize = 18.sp, color = Purple400)
}
Spacer(Modifier.height(12.dp))
LinearProgressIndicator(
progress       = { savingsRate / 100f },
modifier       = Modifier.fillMaxWidth().height(10.dp).clip(RoundedCornerShape(50)),
color          = Purple400,
trackColor     = LightBlue50
)
Spacer(Modifier.height(8.dp))
Text("비활성 구독을 해지하면 연 ₩${"%,d".format(inactiveTotal * 12)}을 절약할 수 있어요",
fontSize = 12.sp, color = TextSecondary)
}
}
}

// Grade breakdown
item { Spacer(Modifier.height(20.dp)) }
item {
Text(
"가성비 분석",
fontWeight = FontWeight.Bold,
fontSize   = 17.sp,
color      = TextPrimary,
modifier   = Modifier.padding(horizontal = 20.dp)
)
}
item { Spacer(Modifier.height(12.dp)) }
item {
Row(
modifier            = Modifier.fillMaxWidth().padding(horizontal = 16.dp),
horizontalArrangement = Arrangement.spacedBy(10.dp)
) {
ValueGrade.entries.forEach { grade ->
val count = subscriptions.count { it.grade == grade }
GradeChip(grade = grade, count = count, modifier = Modifier.weight(1f))
}
}
}
}
}

@Composable
fun SummaryCard(
modifier  : Modifier = Modifier,
label     : String,
value     : String,
sub       : String,
gradient  : List<Color>,
icon      : ImageVector,
iconTint  : Color = Color.White,
textColor : Color = Color.White,
subColor  : Color = Color.White.copy(alpha = 0.8f)
) {
Card(
modifier  = modifier,
shape     = RoundedCornerShape(20.dp),
elevation = CardDefaults.cardElevation(8.dp)
) {
Box(
modifier = Modifier
    .fillMaxWidth()
    .background(Brush.linearGradient(gradient))
    .padding(16.dp)
) {
Column {
Icon(icon, null, tint = iconTint, modifier = Modifier.size(24.dp))
Spacer(Modifier.height(10.dp))
Text(label,  fontSize = 12.sp, color = subColor)
Spacer(Modifier.height(4.dp))
Text(value,  fontSize = 18.sp, fontWeight = FontWeight.Bold, color = textColor)
Text(sub,    fontSize = 11.sp, color = subColor)
}
}
}
}

@Composable
fun GradeChip(grade: ValueGrade, count: Int, modifier: Modifier = Modifier) {
Card(
modifier  = modifier,
shape     = RoundedCornerShape(14.dp),
colors    = CardDefaults.cardColors(containerColor = grade.color.copy(alpha = 0.1f)),
elevation = CardDefaults.cardElevation(0.dp)
) {
Column(
modifier              = Modifier.padding(vertical = 14.dp).fillMaxWidth(),
horizontalAlignment   = Alignment.CenterHorizontally
) {
Text("$count", fontSize = 22.sp, fontWeight = FontWeight.Bold, color = grade.color)
Text("가성비 ${grade.label}", fontSize = 11.sp, color = grade.color.copy(alpha = 0.8f))
}
}
}

// ─────────────────────────────────────────────
//  2. Subscription List Screen
// ─────────────────────────────────────────────
@Composable
fun SubscriptionListScreen(
subscriptions : List<Subscription>,
onToggle      : (Subscription, Boolean) -> Unit
) {
Column(modifier = Modifier.fillMaxSize()) {
// Top bar
Box(
modifier = Modifier
    .fillMaxWidth()
    .background(Brush.linearGradient(listOf(Purple400, Purple300)))
    .padding(top = 52.dp, bottom = 20.dp, start = 24.dp, end = 24.dp)
) {
Text("내 구독 목록", fontSize = 22.sp, fontWeight = FontWeight.Bold, color = Color.White)
}

LazyColumn(
contentPadding      = PaddingValues(16.dp),
verticalArrangement = Arrangement.spacedBy(12.dp)
) {
items(subscriptions, key = { it.id }) { sub ->
SubscriptionCard(subscription = sub, onToggle = { onToggle(sub, it) })
}
}
}
}

@Composable
fun SubscriptionCard(subscription: Subscription, onToggle: (Boolean) -> Unit) {
val alpha by animateFloatAsState(
targetValue   = if (subscription.isActive) 1f else 0.55f,
animationSpec = tween(300),
label         = "alpha"
)
Card(
modifier  = Modifier.fillMaxWidth(),
shape     = RoundedCornerShape(20.dp),
colors    = CardDefaults.cardColors(containerColor = CardWhite),
elevation = CardDefaults.cardElevation(if (subscription.isActive) 4.dp else 1.dp)
) {
Row(
modifier          = Modifier.padding(16.dp).fillMaxWidth(),
verticalAlignment = Alignment.CenterVertically
) {
// Icon circle
Box(
modifier            = Modifier
    .size(48.dp)
    .clip(CircleShape)
    .background(if (subscription.isActive) Purple100 else LightBlue50),
contentAlignment    = Alignment.Center
) {
Icon(
subscription.icon,
contentDescription = null,
tint               = if (subscription.isActive) Purple400 else TextSecondary,
modifier           = Modifier.size(24.dp)
)
}
Spacer(Modifier.width(14.dp))

// Info
Column(modifier = Modifier.weight(1f)) {
Text(
subscription.name,
fontWeight = FontWeight.SemiBold,
fontSize   = 16.sp,
color      = TextPrimary.copy(alpha = alpha)
)
Spacer(Modifier.height(3.dp))
Text(
"₩${"%,d".format(subscription.monthlyFee)} / 월  •  ${subscription.usageHoursPerMonth}h 이용",
fontSize = 12.sp,
color    = TextSecondary.copy(alpha = alpha)
)
Spacer(Modifier.height(6.dp))
Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(6.dp)) {
GradeBadge(subscription.grade)
CategoryChip(subscription.category)
}
}

Spacer(Modifier.width(8.dp))

// Toggle
Switch(
checked       = subscription.isActive,
onCheckedChange = onToggle,
colors        = SwitchDefaults.colors(
checkedThumbColor       = Color.White,
checkedTrackColor       = Purple400,
uncheckedThumbColor     = Color.White,
uncheckedTrackColor     = LightBlue100
)
)
}
}
}

@Composable
fun GradeBadge(grade: ValueGrade) {
Box(
modifier            = Modifier
    .clip(RoundedCornerShape(6.dp))
    .background(grade.color.copy(alpha = 0.15f))
    .padding(horizontal = 8.dp, vertical = 3.dp)
) {
Text("가성비 ${grade.label}", fontSize = 11.sp, color = grade.color, fontWeight = FontWeight.SemiBold)
}
}

@Composable
fun CategoryChip(category: String) {
Box(
modifier            = Modifier
    .clip(RoundedCornerShape(6.dp))
    .background(LightBlue50)
    .padding(horizontal = 8.dp, vertical = 3.dp)
) {
Text(category, fontSize = 11.sp, color = Purple400)
}
}

// ─────────────────────────────────────────────
//  3. Cancellation Guide Bottom Sheet
// ─────────────────────────────────────────────
@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun CancellationGuideSheet(
subscription : Subscription,
sheetState   : SheetState,
onConfirm    : () -> Unit,
onDismiss    : () -> Unit
) {
val steps = listOf(
Triple(Icons.Filled.OpenInBrowser,  "앱 또는 웹사이트 열기",    "${subscription.name} 공식 앱 또는 홈페이지에 접속하세요"),
Triple(Icons.Filled.ManageAccounts, "계정 설정으로 이동",        "우측 상단 프로필 → 계정 설정을 탭하세요"),
Triple(Icons.Filled.CreditCard,     "구독 / 결제 관리",          "'구독 관리' 또는 '멤버십' 메뉴를 선택하세요"),
Triple(Icons.Filled.Cancel,         "구독 해지 선택",             "'구독 취소' 버튼을 누르고 안내에 따라 완료하세요"),
Triple(Icons.Filled.CheckCircle,    "해지 확인 메일 확인",        "해지 완료 이메일을 확인하고 보관하세요")
)

ModalBottomSheet(
onDismissRequest = onDismiss,
sheetState       = sheetState,
shape            = RoundedCornerShape(topStart = 28.dp, topEnd = 28.dp),
containerColor   = CardWhite
) {
Column(
modifier            = Modifier
    .fillMaxWidth()
    .padding(horizontal = 24.dp)
    .padding(bottom = 32.dp),
horizontalAlignment = Alignment.CenterHorizontally
) {
// Handle
Box(
modifier = Modifier
    .width(40.dp)
    .height(4.dp)
    .clip(RoundedCornerShape(2.dp))
    .background(LightBlue100)
)
Spacer(Modifier.height(20.dp))

// Header
Row(verticalAlignment = Alignment.CenterVertically) {
Box(
modifier         = Modifier
    .size(40.dp)
    .clip(CircleShape)
    .background(Purple100),
contentAlignment = Alignment.Center
) {
Icon(subscription.icon, null, tint = Purple400, modifier = Modifier.size(22.dp))
}
Spacer(Modifier.width(12.dp))
Column {
Text(
"${subscription.name} 해지 가이드",
fontWeight = FontWeight.Bold,
fontSize   = 18.sp,
color      = TextPrimary
)
Text(
"아래 단계를 따라 해지를 진행하세요",
fontSize = 12.sp,
color    = TextSecondary
)
}
}

Spacer(Modifier.height(8.dp))

// Savings banner
Box(
modifier = Modifier
    .fillMaxWidth()
    .clip(RoundedCornerShape(14.dp))
    .background(Brush.linearGradient(listOf(LightBlue50, Purple100)))
    .padding(14.dp)
) {
Row(verticalAlignment = Alignment.CenterVertically) {
Icon(Icons.Filled.Savings, null, tint = Purple400, modifier = Modifier.size(22.dp))
Spacer(Modifier.width(10.dp))
Column {
Text("해지 시 절약 금액", fontSize = 12.sp, color = TextSecondary)
Text(
"월 ₩${"%,d".format(subscription.monthlyFee)}  |  연 ₩${"%,d".format(subscription.monthlyFee * 12)}",
fontWeight = FontWeight.Bold,
fontSize   = 15.sp,
color      = Purple400
)
}
}
}

Spacer(Modifier.height(20.dp))

// Steps
steps.forEachIndexed { index, (icon, title, desc) ->
StepRow(step = index + 1, icon = icon, title = title, desc = desc)
if (index < steps.lastIndex) {
Box(
modifier = Modifier
    .padding(start = 19.dp)
    .width(2.dp)
    .height(16.dp)
    .background(LightBlue100)
    .align(Alignment.Start)
)
}
}

Spacer(Modifier.height(24.dp))

// Action buttons
Button(
onClick  = onConfirm,
modifier = Modifier.fillMaxWidth().height(52.dp),
shape    = RoundedCornerShape(16.dp),
colors   = ButtonDefaults.buttonColors(containerColor = Purple400)
) {
Icon(Icons.Filled.CheckCircle, null, modifier = Modifier.size(18.dp))
Spacer(Modifier.width(8.dp))
Text("해지 완료로 표시", fontWeight = FontWeight.SemiBold, fontSize = 15.sp)
}
Spacer(Modifier.height(10.dp))
OutlinedButton(
onClick  = onDismiss,
modifier = Modifier.fillMaxWidth().height(52.dp),
shape    = RoundedCornerShape(16.dp),
border   = BorderStroke(1.5.dp, Purple300)
) {
Text("다시 생각해볼게요", color = Purple400, fontWeight = FontWeight.Medium, fontSize = 15.sp)
}
}
}
}

@Composable
fun StepRow(step: Int, icon: ImageVector, title: String, desc: String) {
Row(verticalAlignment = Alignment.Top) {
// Step badge
Box(
modifier         = Modifier
    .size(38.dp)
    .clip(CircleShape)
    .background(Purple100),
contentAlignment = Alignment.Center
) {
Icon(icon, null, tint = Purple400, modifier = Modifier.size(18.dp))
}
Spacer(Modifier.width(14.dp))
Column(modifier = Modifier.padding(top = 2.dp)) {
Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(6.dp)) {
Box(
modifier         = Modifier
    .size(18.dp)
    .clip(CircleShape)
    .background(Purple400),
contentAlignment = Alignment.Center
) {
Text("$step", fontSize = 10.sp, color = Color.White, fontWeight = FontWeight.Bold)
}
Text(title, fontWeight = FontWeight.SemiBold, fontSize = 14.sp, color = TextPrimary)
}
Spacer(Modifier.height(3.dp))
Text(desc, fontSize = 12.sp, color = TextSecondary, lineHeight = 17.sp)
}
}
}

// ─────────────────────────────────────────────
//  4. Settings Screen (placeholder)
// ─────────────────────────────────────────────
@Composable
fun SettingsScreen() {
Column(modifier = Modifier.fillMaxSize()) {
Box(
modifier = Modifier
    .fillMaxWidth()
    .background(Brush.linearGradient(listOf(Purple400, Purple300)))
    .padding(top = 52.dp, bottom = 20.dp, start = 24.dp, end = 24.dp)
) {
Text("설정", fontSize = 22.sp, fontWeight = FontWeight.Bold, color = Color.White)
}
Column(modifier = Modifier.padding(16.dp), verticalArrangement = Arrangement.spacedBy(12.dp)) {
listOf(
Icons.Filled.Notifications to "알림 설정",
Icons.Filled.Palette       to "테마 변경",
Icons.Filled.Language      to "언어 설정",
Icons.Filled.Security      to "개인정보 보호",
Icons.Filled.Info          to "앱 정보"
).forEach { (icon, label) ->
Card(
shape     = RoundedCornerShape(16.dp),
colors    = CardDefaults.cardColors(containerColor = CardWhite),
elevation = CardDefaults.cardElevation(2.dp)
) {
Row(
modifier          = Modifier.fillMaxWidth().padding(16.dp),
verticalAlignment = Alignment.CenterVertically
) {
Icon(icon, null, tint = Purple400, modifier = Modifier.size(22.dp))
Spacer(Modifier.width(14.dp))
Text(label, fontSize = 15.sp, color = TextPrimary, modifier = Modifier.weight(1f))
Icon(Icons.Filled.ChevronRight, null, tint = TextSecondary, modifier = Modifier.size(20.dp))
}
}
}
}
}
}

// ─────────────────────────────────────────────
//  Preview
// ─────────────────────────────────────────────
@Preview(showBackground = true, showSystemUi = true)
@Composable
fun OffSubPreview() {
OffSubTheme { OffSubApp() }
}
