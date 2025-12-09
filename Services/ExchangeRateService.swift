import Foundation

// MARK: - Exchange Rate Response Model
struct ExchangeRateResponse: Codable {
    let result: Int
    let curUnit: String
    let curNm: String
    let ttb: String?
    let tts: String?
    let dealBasR: String?
    let bkpr: String?
    let yyEfeeR: String?
    let tenDdEfeeR: String?
    let kftcDealBasR: String?
    let kftcBkpr: String?

    enum CodingKeys: String, CodingKey {
        case result
        case curUnit = "cur_unit"
        case curNm = "cur_nm"
        case ttb
        case tts
        case dealBasR = "deal_bas_r"
        case bkpr
        case yyEfeeR = "yy_efee_r"
        case tenDdEfeeR = "ten_dd_efee_r"
        case kftcDealBasR = "kftc_deal_bas_r"
        case kftcBkpr = "kftc_bkpr"
    }
}

// MARK: - Exchange Rate Model
struct ExchangeRate: Identifiable {
    let id = UUID()
    let currencyCode: String
    let currencyName: String
    let baseRate: Double
    let buyRate: Double?
    let sellRate: Double?
    let lastUpdated: Date

    init(from response: ExchangeRateResponse, lastUpdated: Date = Date()) {
        self.currencyCode = response.curUnit
        self.currencyName = response.curNm
        self.baseRate = Double(response.dealBasR?.replacingOccurrences(of: ",", with: "") ?? "0") ?? 0
        self.buyRate = Double(response.ttb?.replacingOccurrences(of: ",", with: "") ?? "0")
        self.sellRate = Double(response.tts?.replacingOccurrences(of: ",", with: "") ?? "0")
        self.lastUpdated = lastUpdated
    }

    var flag: String {
        // 통화 코드에서 괄호 제거 (JPY(100) -> JPY)
        let cleanCode = currencyCode.components(separatedBy: "(").first ?? currencyCode

        switch cleanCode {
        // 주요 통화
        case "USD": return "🇺🇸"  // 미국 달러
        case "JPY": return "🇯🇵"  // 일본 엔
        case "EUR": return "🇪🇺"  // 유로
        case "CNH", "CNY": return "🇨🇳"  // 중국 위안
        case "GBP": return "🇬🇧"  // 영국 파운드
        case "CHF": return "🇨🇭"  // 스위스 프랑
        case "CAD": return "🇨🇦"  // 캐나다 달러
        case "AUD": return "🇦🇺"  // 호주 달러

        // 아시아/태평양
        case "HKD": return "🇭🇰"  // 홍콩 달러
        case "SGD": return "🇸🇬"  // 싱가포르 달러
        case "THB": return "🇹🇭"  // 태국 바트
        case "MYR": return "🇲🇾"  // 말레이시아 링깃
        case "IDR": return "🇮🇩"  // 인도네시아 루피아
        case "PHP": return "🇵🇭"  // 필리핀 페소
        case "VND": return "🇻🇳"  // 베트남 동
        case "TWD": return "🇹🇼"  // 대만 달러
        case "INR": return "🇮🇳"  // 인도 루피
        case "PKR": return "🇵🇰"  // 파키스탄 루피
        case "BDT": return "🇧🇩"  // 방글라데시 타카
        case "LKR": return "🇱🇰"  // 스리랑카 루피
        case "MMK": return "🇲🇲"  // 미얀마 차트
        case "KHR": return "🇰🇭"  // 캄보디아 리엘
        case "LAK": return "🇱🇦"  // 라오스 킵
        case "BND": return "🇧🇳"  // 브루나이 달러
        case "MOP": return "🇲🇴"  // 마카오 파타카
        case "NZD": return "🇳🇿"  // 뉴질랜드 달러
        case "FJD": return "🇫🇯"  // 피지 달러

        // 중동
        case "AED": return "🇦🇪"  // 아랍에미리트 디르함
        case "BHD": return "🇧🇭"  // 바레인 디나르
        case "SAR": return "🇸🇦"  // 사우디 리얄
        case "KWD": return "🇰🇼"  // 쿠웨이트 디나르
        case "OMR": return "🇴🇲"  // 오만 리알
        case "QAR": return "🇶🇦"  // 카타르 리얄
        case "JOD": return "🇯🇴"  // 요르단 디나르
        case "ILS": return "🇮🇱"  // 이스라엘 셰켈
        case "EGP": return "🇪🇬"  // 이집트 파운드
        case "IRR": return "🇮🇷"  // 이란 리알
        case "IQD": return "🇮🇶"  // 이라크 디나르
        case "LBP": return "🇱🇧"  // 레바논 파운드

        // 유럽
        case "NOK": return "🇳🇴"  // 노르웨이 크로네
        case "SEK": return "🇸🇪"  // 스웨덴 크로나
        case "DKK": return "🇩🇰"  // 덴마크 크로네
        case "ISK": return "🇮🇸"  // 아이슬란드 크로나
        case "CZK": return "🇨🇿"  // 체코 코루나
        case "PLN": return "🇵🇱"  // 폴란드 즐로티
        case "HUF": return "🇭🇺"  // 헝가리 포린트
        case "RON": return "🇷🇴"  // 루마니아 레우
        case "BGN": return "🇧🇬"  // 불가리아 레프
        case "HRK": return "🇭🇷"  // 크로아티아 쿠나
        case "RSD": return "🇷🇸"  // 세르비아 디나르
        case "RUB": return "🇷🇺"  // 러시아 루블
        case "UAH": return "🇺🇦"  // 우크라이나 흐리브냐
        case "TRY": return "🇹🇷"  // 터키 리라
        case "GEL": return "🇬🇪"  // 조지아 라리
        case "AMD": return "🇦🇲"  // 아르메니아 드람
        case "AZN": return "🇦🇿"  // 아제르바이잔 마나트

        // 아메리카
        case "MXN": return "🇲🇽"  // 멕시코 페소
        case "BRL": return "🇧🇷"  // 브라질 헤알
        case "ARS": return "🇦🇷"  // 아르헨티나 페소
        case "CLP": return "🇨🇱"  // 칠레 페소
        case "COP": return "🇨🇴"  // 콜롬비아 페소
        case "PEN": return "🇵🇪"  // 페루 솔
        case "UYU": return "🇺🇾"  // 우루과이 페소
        case "VEF", "VES": return "🇻🇪"  // 베네수엘라 볼리바르
        case "BOB": return "🇧🇴"  // 볼리비아 볼리비아노
        case "PYG": return "🇵🇾"  // 파라과이 과라니
        case "JMD": return "🇯🇲"  // 자메이카 달러
        case "TTD": return "🇹🇹"  // 트리니다드토바고 달러

        // 아프리카
        case "ZAR": return "🇿🇦"  // 남아프리카 공화국 랜드
        case "EGP": return "🇪🇬"  // 이집트 파운드
        case "NGN": return "🇳🇬"  // 나이지리아 나이라
        case "KES": return "🇰🇪"  // 케냐 실링
        case "GHS": return "🇬🇭"  // 가나 세디
        case "TZS": return "🇹🇿"  // 탄자니아 실링
        case "UGX": return "🇺🇬"  // 우간다 실링
        case "MAD": return "🇲🇦"  // 모로코 디르함
        case "TND": return "🇹🇳"  // 튀니지 디나르
        case "DZD": return "🇩🇿"  // 알제리 디나르
        case "XOF", "XAF": return "🌍"  // 서/중앙 아프리카 프랑

        // 기타 통화
        case "KZT": return "🇰🇿"  // 카자흐스탄 텡게
        case "UZS": return "🇺🇿"  // 우즈베키스탄 숨
        case "MNT": return "🇲🇳"  // 몽골 투그릭
        case "KGS": return "🇰🇬"  // 키르기스스탄 솜
        case "TJS": return "🇹🇯"  // 타지키스탄 소모니
        case "TMT": return "🇹🇲"  // 투르크메니스탄 마나트

        default: return "🌍"  // 기본 지구 아이콘
        }
    }

    var displayName: String {
        switch currencyCode {
        case "JPY(100)": return "JPY"
        default: return currencyCode
        }
    }
}

class ExchangeRateService: ObservableObject {
    static let shared = ExchangeRateService()

    @Published var exchangeRates: [ExchangeRate] = []
    @Published var lastUpdated: Date?
    @Published var isLoading = false
    @Published var errorMessage: String?

    // 한국 수출입은행 API Key
    private let apiKey = Config.exchangeRateAPIKey
    private let baseURL = "https://www.koreaexim.go.kr/site/program/financial/exchangeJSON"

    // 우선순위 통화 (먼저 표시할 통화)
    private let priorityCurrencies = ["USD", "JPY(100)", "EUR", "GBP"]

    private init() {}

    // MARK: - Fetch Exchange Rates
    func fetchExchangeRates() async {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        let today = dateFormatter.string(from: Date())

        guard var urlComponents = URLComponents(string: baseURL) else {
            await MainActor.run {
                isLoading = false
                errorMessage = "잘못된 URL"
            }
            return
        }

        urlComponents.queryItems = [
            URLQueryItem(name: "authkey", value: apiKey),
            URLQueryItem(name: "searchdate", value: today),
            URLQueryItem(name: "data", value: "AP01")
        ]

        guard let url = urlComponents.url else {
            await MainActor.run {
                isLoading = false
                errorMessage = "URL 생성 실패"
            }
            return
        }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let responses = try JSONDecoder().decode([ExchangeRateResponse].self, from: data)

            let now = Date()
            // 모든 환율 정보를 가져오되, 우선순위에 따라 정렬
            let rates = responses
                .map { ExchangeRate(from: $0, lastUpdated: now) }
                .sorted { rate1, rate2 in
                    let priority1 = priorityCurrencies.firstIndex(of: rate1.currencyCode) ?? Int.max
                    let priority2 = priorityCurrencies.firstIndex(of: rate2.currencyCode) ?? Int.max

                    if priority1 != priority2 {
                        return priority1 < priority2
                    }
                    return rate1.currencyCode < rate2.currencyCode
                }

            await MainActor.run {
                self.exchangeRates = rates
                self.lastUpdated = now
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.isLoading = false
                self.errorMessage = "환율 정보를 가져올 수 없습니다: \(error.localizedDescription)"
            }
        }
    }

    // MARK: - Legacy Support
    func getRate(for currency: Currency) async -> Double {
        if exchangeRates.isEmpty {
            await fetchExchangeRates()
        }

        let code = currency.rawValue.uppercased()
        let exchangeRate = exchangeRates.first { $0.currencyCode == code || $0.displayName == code }
        return exchangeRate?.baseRate ?? 1.0
    }

    func convert(amount: Double, from source: Currency, to target: Currency) async -> Double {
        let sourceRate = await getRate(for: source)
        let targetRate = await getRate(for: target)

        return amount * sourceRate / targetRate
    }
}
