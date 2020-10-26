//
//  PDFCreator.swift
//  QuickInvoice
//
//  Created by Alex Drewno on 8/19/20.
//  Copyright © 2020 Alex Drewno. All rights reserved.
//

import PDFKit

// TODO: Refactor the way to make PDFs into Header/Body/End
class PDFCreator: NSObject {
    
    var title: String
    var date: String
    var client: Client?
    var items: [InvoiceItem]
    var estimatedTotal: String
    var actualTotal: String
    var otherComments: String
    var jobDescription: String
    
    init(title: String, date: String, jobDescription: String, client: Client?, items: [InvoiceItem], estimatedTotal: String, actualTotal: String, otherComments: String) {
        self.title = title
        self.date = date
        self.jobDescription = jobDescription
        self.client = client
        self.items = items
        self.estimatedTotal = estimatedTotal
        self.actualTotal = actualTotal
        self.otherComments = otherComments
    }
    
    // MARK: - Classic Style PDF
    func classicStylePDF(size: CGRect = CGRect(x: 0, y: 0, width: 8.5 * 72.0, height: 11 * 72.0)) -> Data {
        let pdfMetaData = [
          kCGPDFContextCreator: "Quick Invoice",
          kCGPDFContextAuthor: ""
        ]
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]

        let renderer = UIGraphicsPDFRenderer(bounds: size, format: format)
        
        let curUserInfo = fetchCurUserInformation()

        let data = renderer.pdfData { (context) in

            context.beginPage()

            var attributes = [
                NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 26)
            ]
            let attributedTitle = NSAttributedString(string: title, attributes: attributes)
            let attributedTitleSize = attributedTitle.size()
            attributedTitle.draw(at: CGPoint(x: CGFloat(size.width/2) - attributedTitleSize.width/2, y: 15))
            
            
            attributes = [
                NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16, weight: .bold)
            ]
            let attributedDate = NSAttributedString(string: date, attributes: attributes)
            let attributedDateSize = attributedDate.size()
            attributedDate.draw(at: CGPoint(x: CGFloat(size.width) - attributedDateSize.width - 20, y: attributedTitleSize.height - attributedDateSize.height + 15))
            
            
            attributes = [
                NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16, weight: .bold)
            ]
            let attributedCurUserName = NSAttributedString(string: curUserInfo?.name ?? "", attributes: attributes)
            let attributedCurUserNameSize = attributedCurUserName.size()
            attributedCurUserName.draw(at: CGPoint(x: 20, y: attributedTitleSize.height - attributedCurUserNameSize.height + 15))
            
            attributes = [
                NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12, weight: .regular)
            ]
            let attributedStreetAddress = NSAttributedString(string: curUserInfo?.streetAddress ?? "", attributes: attributes)
            let attributedStreetAddressSize = attributedStreetAddress.size()
            attributedStreetAddress.draw(at: CGPoint(x: 20, y: attributedTitleSize.height - attributedCurUserNameSize.height + attributedStreetAddressSize.height + 25))
            
            let attributedrestofAddress = NSAttributedString(string: curUserInfo?.restofAddress ?? "", attributes: attributes)
            let attributedrestofAddressSize = attributedrestofAddress.size()
            attributedrestofAddress.draw(at: CGPoint(x: 20, y: attributedTitleSize.height - attributedCurUserNameSize.height + attributedStreetAddressSize.height + attributedrestofAddressSize.height + 25))
            
            let atelephone = NSAttributedString(string: curUserInfo?.telephone ?? "", attributes: attributes)
            let atelephoneSize = atelephone.size()
            atelephone.draw(at: CGPoint(x: 20, y: attributedTitleSize.height - attributedCurUserNameSize.height + attributedStreetAddressSize.height + attributedrestofAddressSize.height +
                atelephoneSize.height + 25))
            
            let aemail = NSAttributedString(string: curUserInfo?.email ?? "", attributes: attributes)
            let aemailSize = aemail.size()
            aemail.draw(at: CGPoint(x: 20, y: attributedTitleSize.height - attributedCurUserNameSize.height + attributedStreetAddressSize.height + attributedrestofAddressSize.height +
                atelephoneSize.height +
                aemailSize.height + 25))
            
            if let c = client {
                
                attributes = [
                    NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16, weight: .bold)
                ]
                
                let aservice = NSAttributedString(string: "Service ordered by: " + (c.clientName ?? ""), attributes: attributes)
                aservice.draw(at: CGPoint(x: Double(size.width)/2 - Double(aservice.size().width)/2, y: Double(size.height*0.075)))
                
                attributes = [
                    NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16, weight: .regular)
                ]
                
                let acStreet = NSAttributedString(string: (c.streetAddress ?? ""), attributes: attributes)
                acStreet.draw(at: CGPoint(x: CGFloat(size.width/2) - acStreet.size().width/2, y: CGFloat(size.height*0.075) + acStreet.size().height))
                
                let acTelephone = NSAttributedString(string: (c.telephone ?? ""), attributes: attributes)
                acTelephone.draw(at: CGPoint(x: CGFloat(size.width/2) - acTelephone.size().width/2, y: CGFloat(size.height*0.075) + acStreet.size().height + acTelephone.size().height))
                
                let acEmail = NSAttributedString(string: (c.email ?? ""), attributes: attributes)
                acEmail.draw(at: CGPoint(x: CGFloat(size.width/2) - acEmail.size().width/2, y: CGFloat(size.height*0.075) + acStreet.size().height + acTelephone.size().height + acEmail.size().height))
                
            }
            
            let LINE_Y = CGFloat(size.height/5)
            
            context.cgContext.setLineWidth(1)
            context.cgContext.move(to: CGPoint(x: 0, y: LINE_Y))
            context.cgContext.addLine(to: CGPoint(x: size.width, y: LINE_Y))
            context.cgContext.strokePath()
            
            context.cgContext.move(to: CGPoint(x: 0, y: LINE_Y+30))
            context.cgContext.addLine(to: CGPoint(x: size.width, y: LINE_Y+30))
            context.cgContext.strokePath()
            
            let endOfBody = self.drawBody(in: context, startingPosition: CGPoint(x: 20, y: LINE_Y), size: size.size)
            drawFooter(in: context, startingPosition: CGPoint(x: 0, y: endOfBody))
        }

        return data
    }
    
    // MARK: - Special Style pdf
    func specialStylePDF(size: CGRect = CGRect(x: 0, y: 0, width: 8.5 * 72.0, height: 11 * 72.0)) -> Data {
    
        let pdfMetaData = [
          kCGPDFContextCreator: "Quick Invoice",
          kCGPDFContextAuthor: ""
        ]
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]

        let renderer = UIGraphicsPDFRenderer(bounds: size, format: format)
        
        let curUserInfo = fetchCurUserInformation()
        
        let data = renderer.pdfData { (context) in
            context.beginPage()

            
            let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height/5.5)
            context.fill(rect)
            
            
            var attributes = [
                NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 28),
                NSAttributedString.Key.foregroundColor: UIColor.white
            ]
            let attributedTitle = NSAttributedString(string: curUserInfo?.name ?? "(Company Name)", attributes: attributes)
            let attributedTitleSize = attributedTitle.size()
            attributedTitle.draw(at: CGPoint(x: 20, y: 20))
            
            attributes = [
                NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 22),
                NSAttributedString.Key.foregroundColor: UIColor.white
            ]
            let at = NSAttributedString(string: title, attributes: attributes)
            at.draw(at: CGPoint(x: size.width-at.size().width-20, y: 26))
            
            attributes = [
                NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12),
                NSAttributedString.Key.foregroundColor: UIColor.white
            ]

            let c1 = NSAttributedString(string: curUserInfo?.streetAddress ?? "(Street Address)", attributes: attributes)
            c1.draw(at: CGPoint(x: 20, y: 30+attributedTitle.size().height))
            
            let c2 = NSAttributedString(string: curUserInfo?.restofAddress ?? "(Street Address2)", attributes: attributes)
            c2.draw(at: CGPoint(x: 20, y: 30+c1.size().height+attributedTitle.size().height))
            
            let c3 = NSAttributedString(string: curUserInfo?.telephone ?? "(Telephone)", attributes: attributes)
            c3.draw(at: CGPoint(x: 20, y: 30+c1.size().height+c2.size().height+attributedTitle.size().height))
            
            let c4 = NSAttributedString(string: curUserInfo?.email ?? "(Email)", attributes: attributes)
            c4.draw(at: CGPoint(x: 20, y: 30+c1.size().height+c2.size().height+c3.size().height+attributedTitle.size().height))
            
            let endOfBody = self.drawBody(in: context, startingPosition: CGPoint(x: 20, y: size.height/5.5+5), size: size.size)
            drawFooter(in: context, startingPosition: CGPoint(x: 0, y: endOfBody))
            
        }
        return data
    }
    
    // MARK: - Second Style PDF
    func secondStylePDF(size: CGRect = CGRect(x: 0, y: 0, width: 8.5 * 72.0, height: 11 * 72.0)) -> Data {
        let pdfMetaData = [
          kCGPDFContextCreator: "Quick Invoice",
          kCGPDFContextAuthor: ""
        ]
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]

        let renderer = UIGraphicsPDFRenderer(bounds: size, format: format)
        
        let curUserInfo = fetchCurUserInformation()
        
        let data = renderer.pdfData { (context) in

            context.beginPage()

            var attributes = [
                NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 28)
            ]
            let attributedTitle = NSAttributedString(string: curUserInfo?.name ?? "(Company Name)", attributes: attributes)
            let attributedTitleSize = attributedTitle.size()
            attributedTitle.draw(at: CGPoint(x: 20, y: 20))
            
            attributes = [
                NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 22),
            ]
            let at = NSAttributedString(string: title, attributes: attributes)
            at.draw(at: CGPoint(x: 20, y: attributedTitleSize.height+20))
            
            attributes = [
                NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12)
            ]
            let c1 = NSAttributedString(string: curUserInfo?.streetAddress ?? "(Street Address)", attributes: attributes)
            c1.draw(at: CGPoint(x: size.width-c1.size().width-20, y: 30))
            
            let c2 = NSAttributedString(string: curUserInfo?.restofAddress ?? "(Street Address2)", attributes: attributes)
            c2.draw(at: CGPoint(x: size.width-c2.size().width-20, y: 30+c1.size().height))
            
            let c3 = NSAttributedString(string: curUserInfo?.telephone ?? "(Telephone)", attributes: attributes)
            c3.draw(at: CGPoint(x: size.width-c3.size().width-20, y: 30+c1.size().height+c2.size().height))
            
            let c4 = NSAttributedString(string: curUserInfo?.email ?? "(Email)", attributes: attributes)
            c4.draw(at: CGPoint(x: size.width-c4.size().width-20, y: 30+c1.size().height+c2.size().height+c3.size().height))
            
            let attributes2 = [
                NSMutableAttributedString.Key.foregroundColor: UIColor.gray,
                NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12)
            ]
            
            let d1 = NSMutableAttributedString(string: "Client Information", attributes: attributes2)
            d1.draw(at: CGPoint(x: 20, y: attributedTitleSize.height+at.size().height+30))
            
            let d2 = NSAttributedString(string: client?.clientName ?? "(Client Name)", attributes: attributes)
            d2.draw(at: CGPoint(x: 20, y: attributedTitleSize.height+at.size().height+30+d1.size().height))
            
            let d3 = NSAttributedString(string: client?.streetAddress ?? "(Client StreetAddress)", attributes: attributes)
            d3.draw(at: CGPoint(x: 20, y: attributedTitleSize.height+at.size().height+30+d1.size().height+d2.size().height))
            
            let d4 = NSAttributedString(string: client?.restofAddress ?? "(Client StreetAddress2)", attributes: attributes)
            d4.draw(at: CGPoint(x: 20, y: attributedTitleSize.height+at.size().height+30+d1.size().height+d2.size().height+d3.size().height))
            
            let d5 = NSAttributedString(string: client?.telephone ?? "(Client Telephone)", attributes: attributes)
            d5.draw(at: CGPoint(x: 20, y: attributedTitleSize.height+at.size().height+30+d1.size().height+d2.size().height+d3.size().height+d4.size().height))
            
            context.cgContext.setLineWidth(0.6)
            context.cgContext.move(to: CGPoint(x: 0, y: attributedTitleSize.height+at.size().height+40+d1.size().height+d2.size().height+d3.size().height+d4.size().height+d5.size().height))
            context.cgContext.addLine(to: CGPoint(x: size.width, y: attributedTitleSize.height+at.size().height+40+d1.size().height+d2.size().height+d3.size().height+d4.size().height+d5.size().height))
            context.cgContext.strokePath()
            
            var LINE_Y = attributedTitleSize.height+at.size().height+40+d1.size().height+d2.size().height+d3.size().height+d4.size().height+d5.size().height
            
            let endOfBody = drawBody(in: context, startingPosition: CGPoint(x: 20, y: LINE_Y), size: size.size)

            drawFooter(in: context, startingPosition: CGPoint(x: 0, y: endOfBody))
        }

        return data
    }
    
    
    // MARK: - Draw Component Functions
    
    // Draw body returns the end of the body (the y-value)
    func drawBody(in context: UIGraphicsPDFRendererContext, startingPosition: CGPoint, size: CGSize) -> CGFloat {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .natural
        paragraphStyle.lineBreakMode = .byWordWrapping
        paragraphStyle.lineHeightMultiple = 0
        
        var textAttributes = [
            NSAttributedString.Key.paragraphStyle: paragraphStyle,
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 10, weight: .light),
            NSAttributedString.Key.foregroundColor: UIColor.gray,
        ]
        
        let cur_height = startingPosition.y
        
        let eq = NSAttributedString(string: "Estimated Quantity", attributes: textAttributes)
        eq.draw(in: CGRect(x: startingPosition.x, y: cur_height+17-eq.size().height-2, width: 60, height: 30))
        
        let aq = NSAttributedString(string: "Actual Quantity", attributes: textAttributes)
        aq.draw(in: CGRect(x: startingPosition.x + 54, y: cur_height+17-aq.size().height-2, width: 60, height: 30))

        let iN = NSAttributedString(string: "Item Name", attributes: textAttributes)
        iN.draw(in: CGRect(x: startingPosition.x + 114, y: cur_height+30-iN.size().height-2, width: 150, height: 30))
        
        let iD = NSAttributedString(string: "Item Description", attributes: textAttributes)
        iD.draw(in: CGRect(x: size.width/2 - iD.size().width/2-15, y: cur_height+30-iD.size().height-2, width: 250, height: 30))
        
        let et = NSAttributedString(string: "Estimated Cost", attributes: textAttributes)
        et.draw(in: CGRect(x: 495, y: cur_height+17-eq.size().height-2, width: 50, height: 30))
        
        let at = NSAttributedString(string: "Actual Cost", attributes: textAttributes)
        at.draw(in: CGRect(x: 555, y: cur_height+17-eq.size().height-2, width: 50, height: 30))
        
        var count = 1

        textAttributes = [
            NSAttributedString.Key.paragraphStyle: paragraphStyle,
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 10, weight: .light),
            NSAttributedString.Key.foregroundColor: UIColor.black,
        ]
        
        for item in items {
            let itemeq = NSAttributedString(string: "\(item.estimatedQuantity)", attributes: textAttributes)
            itemeq.draw(in: CGRect(x: startingPosition.x+aq.size().width/4-itemeq.size().width/2, y: cur_height+15+23*CGFloat(count), width: 60, height: 20))
            
            let itemaq = NSAttributedString(string: "\(item.actualQuantity)", attributes: textAttributes)
            itemaq.draw(in: CGRect(x: startingPosition.x+aq.size().width/4+54-itemaq.size().width/2, y: cur_height+15+23*CGFloat(count), width: 60, height: 20))
            
            let itemname = NSAttributedString(string: item.item?.itemName ?? "", attributes: textAttributes)
            var boundingrect = itemname.boundingRect(with: CGSize(width: 120, height: 40), options: .usesLineFragmentOrigin, context: nil)
            
            if boundingrect.height >= 16 {
                itemname.draw(in: CGRect(x: startingPosition.x + 114, y: cur_height+10+23*CGFloat(count), width: 120, height: 40))
            } else {
                itemname.draw(in: CGRect(x: startingPosition.x + 114, y: cur_height+15+23*CGFloat(count), width: 120, height: 40))
            }
            

            
            let itemdescription = NSAttributedString(string: item.item?.itemDescription ?? "", attributes: textAttributes)
            boundingrect = itemdescription.boundingRect(with: CGSize(width: 250, height: 40), options: .usesLineFragmentOrigin, context: nil)
          
            if boundingrect.height >= 16 {
                itemdescription.draw(in: CGRect(x: size.width/2 - iD.size().width/2-15, y: cur_height+10+23*CGFloat(count), width: 250, height: 40))
            } else {
                itemdescription.draw(in: CGRect(x: size.width/2 - iD.size().width/2-15, y: cur_height+15+23*CGFloat(count), width: 250, height: 40))
            }
            
            let eqp = NSAttributedString(string: "$" + String(format: "%.2f", ((item.item?.itemPrice ?? 0)*Float(item.estimatedQuantity))), attributes: textAttributes)
            eqp.draw(in: CGRect(x: 495, y: cur_height+15+23*CGFloat(count), width: 80, height: 20))
            let aqp = NSAttributedString(string: "$" + String(format: "%.2f", ((item.item?.itemPrice ?? 0)*Float(item.actualQuantity))), attributes: textAttributes)
            aqp.draw(in: CGRect(x: 555, y: cur_height+15+23*CGFloat(count), width: 80, height: 20))
            
            count += 1
        }
        
        return cur_height+25+23*CGFloat(count)
    }
    
    func drawHeader(in context: UIGraphicsPDFRendererContext, startingPosition: CGPoint) {
        
    }
    
    func drawFooter(in context: UIGraphicsPDFRendererContext, startingPosition: CGPoint) {
        
        var textAttributes1 = [
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 10),
            NSMutableAttributedString.Key.foregroundColor: UIColor.gray,
        ]


        let et_title = NSAttributedString(string: "Estimated Total: ", attributes: textAttributes1)
        et_title.draw(in: CGRect(x: 530 - et_title.size().width, y: startingPosition.y, width: 100, height: 20))
        
        textAttributes1 = [
            NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 10),
            NSMutableAttributedString.Key.foregroundColor: UIColor.black,
        ]
        
        let et = NSMutableAttributedString(string: "$"  + estimatedTotal, attributes: textAttributes1)
        et.draw(in: CGRect(x: 540, y: startingPosition.y, width: 100, height: 20))
        
        textAttributes1 = [
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 10),
            NSMutableAttributedString.Key.foregroundColor: UIColor.gray,
        ]

        let aat_title = NSAttributedString(string: "Actual Total: ", attributes: textAttributes1)
        aat_title.draw(in: CGRect(x: 530 - aat_title.size().width, y: startingPosition.y+23, width: 100, height: 20))
        
        textAttributes1 = [
            NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 10),
            NSMutableAttributedString.Key.foregroundColor: UIColor.black,
        ]

        let aat = NSMutableAttributedString(string: "$" + actualTotal, attributes: textAttributes1)
        aat.draw(in: CGRect(x: 540, y: startingPosition.y+23, width: 100, height: 20))
        
        textAttributes1 = [
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 10),
            NSMutableAttributedString.Key.foregroundColor: UIColor.gray,
        ]

        
        let ac = NSMutableAttributedString(string: "Additional Comments", attributes: textAttributes1)
        ac.draw(in: CGRect(x: 20, y: startingPosition.y, width: 150, height: 40))
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .natural
        paragraphStyle.lineBreakMode = .byWordWrapping
        paragraphStyle.lineHeightMultiple = 0
        
        textAttributes1 = [
            NSAttributedString.Key.paragraphStyle: paragraphStyle,
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 10),
            NSMutableAttributedString.Key.foregroundColor: UIColor.black,
        ]
        
        let aac = NSMutableAttributedString(string: "\(otherComments)", attributes: textAttributes1)
        aac.draw(in: CGRect(x: 20, y: startingPosition.y+ac.size().height, width: 400, height: 200))
    }
    
    
}
