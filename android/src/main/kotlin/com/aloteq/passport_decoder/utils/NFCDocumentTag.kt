package com.aloteq.passport_decoder.utils

import android.R.attr.bitmap
import android.graphics.Bitmap
import android.nfc.Tag
import android.nfc.tech.IsoDep
import android.util.Base64
import com.aloteq.passport_decoder.data.AdditionalPersonDetails
import com.aloteq.passport_decoder.data.Passport
import com.aloteq.passport_decoder.data.PersonDetails
import io.reactivex.Single
import io.reactivex.android.schedulers.AndroidSchedulers
import io.reactivex.disposables.Disposable
import io.reactivex.schedulers.Schedulers
import net.sf.scuba.smartcards.CardService
import net.sf.scuba.smartcards.CardServiceException
import org.jmrtd.*
import org.jmrtd.lds.icao.DG1File
import java.io.ByteArrayOutputStream
import java.nio.ByteBuffer
import java.security.Security


class NFCDocumentTag {

    fun handleTag(
            tag: Tag,
            documentNumber: String?,
            dateOfBirth: String?,
            dateOfExpiry: String?,
            mrtdTrustStore: MRTDTrustStore,
            passportCallback: PassportCallback
    ): Disposable {
        return Single.fromCallable {
            var passport: Passport? = null
            var cardServiceException: Exception? = null

            var ps: PassportService? = null
            try {
                val nfc = IsoDep.get(tag)
                nfc.timeout = 5 * 1000 //5 seconds timeout
                val cs = CardService.getInstance(nfc)
                ps = PassportService(cs, 256, 224, false, true)
                ps.open()

                val passportNFC = PassportNFC(ps, mrtdTrustStore, documentNumber, dateOfBirth, dateOfExpiry)

                passport = Passport()

                passport.featureStatus = passportNFC.features
                passport.verificationStatus = passportNFC.verificationStatus


                passport.sodFile = passportNFC.sodFile
                passport.mrz = passportNFC.mrz

                //Basic Information
                if (passportNFC.dg1File != null) {
                    val mrzInfo = (passportNFC.dg1File as DG1File).mrzInfo
                    val personDetails = PersonDetails()
                    personDetails.dateOfBirth = mrzInfo.dateOfBirth
                    personDetails.dateOfExpiry = mrzInfo.dateOfExpiry
                    personDetails.documentCode = mrzInfo.documentCode
                    personDetails.documentNumber = mrzInfo.documentNumber
                    personDetails.optionalData1 = mrzInfo.optionalData1
                    personDetails.optionalData2 = mrzInfo.optionalData2
                    personDetails.issuingState = mrzInfo.issuingState
                    personDetails.primaryIdentifier = mrzInfo.primaryIdentifier
                    personDetails.secondaryIdentifier = mrzInfo.secondaryIdentifier
                    personDetails.nationality = mrzInfo.nationality
                    personDetails.gender = mrzInfo.gender
                    passport.personDetails = personDetails
                }

                val dg11 = passportNFC.dg11File
                if (dg11 != null) {

                    val additionalPersonDetails = AdditionalPersonDetails()
                    additionalPersonDetails.custodyInformation = dg11.custodyInformation
                    additionalPersonDetails.fullDateOfBirth = dg11.fullDateOfBirth
                    additionalPersonDetails.nameOfHolder = dg11.nameOfHolder
                    additionalPersonDetails.otherNames = dg11.otherNames
                    additionalPersonDetails.otherNames = dg11.otherNames
                    additionalPersonDetails.otherValidTDNumbers = dg11.otherValidTDNumbers
                    additionalPersonDetails.permanentAddress = dg11.permanentAddress
                    additionalPersonDetails.personalNumber = dg11.personalNumber
                    additionalPersonDetails.personalSummary = dg11.personalSummary
                    additionalPersonDetails.placeOfBirth = dg11.placeOfBirth
                    additionalPersonDetails.profession = dg11.profession
                    additionalPersonDetails.proofOfCitizenship = dg11.proofOfCitizenship
                    additionalPersonDetails.tag = dg11.tag
                    additionalPersonDetails.tagPresenceList = dg11.tagPresenceList
                    additionalPersonDetails.telephone = dg11.telephone
                    additionalPersonDetails.title = dg11.title

                    passport.additionalPersonDetails = additionalPersonDetails
                }
                //Picture
                if (passportNFC.dg2File != null) {
                    //Get the picture
                    try {
                        val faceImage = PassportNfcUtils.retrieveFaceImage(passportNFC.dg2File!!)

                        val stream = ByteArrayOutputStream()
                        faceImage.compress(Bitmap.CompressFormat.JPEG, 100, stream)
                        val byteArray: ByteArray = stream.toByteArray()
                        faceImage.recycle()
                        val encoded: String = Base64.encodeToString(byteArray, Base64.DEFAULT)
                        passport.face = faceImage
                        passport.faceArray = encoded
                    } catch (e: Exception) {    
                        //Don't do anything
                        e.printStackTrace()
                    }

                }

                //TODO EAC
            } catch (e: Exception) {
                cardServiceException = e
            } finally {
                try {
                    ps?.close()
                } catch (ex: Exception) {
                    ex.printStackTrace()
                }
            }

            PassportDTO(passport, cardServiceException)
        }
                .doOnSubscribe {
                    passportCallback.onPassportReadStart()
                }
                .subscribeOn(Schedulers.io()).observeOn(AndroidSchedulers.mainThread()).subscribe { passportDTO ->
                    if (passportDTO.cardServiceException != null) {
                        val cardServiceException = passportDTO.cardServiceException
                        if (cardServiceException is AccessDeniedException) {
                            passportCallback.onAccessDeniedException(cardServiceException)
                        } else if (cardServiceException is BACDeniedException) {
                            passportCallback.onBACDeniedException(cardServiceException)
                        } else if (cardServiceException is PACEException) {
                            passportCallback.onPACEException(cardServiceException)
                        } else if (cardServiceException is CardServiceException) {
                            passportCallback.onCardException(cardServiceException)
                        } else {
                            passportCallback.onGeneralException(cardServiceException)
                        }
                    } else {
                        passportCallback.onPassportRead(passportDTO.passport)
                    }
                    passportCallback.onPassportReadFinish()
                }
    }

    data class PassportDTO(val passport: Passport? = null, val cardServiceException: Exception? = null)

    interface PassportCallback {
        fun onPassportReadStart()
        fun onPassportReadFinish()
        fun onPassportRead(passport: Passport?)
        fun onAccessDeniedException(exception: AccessDeniedException)
        fun onBACDeniedException(exception: BACDeniedException)
        fun onPACEException(exception: PACEException)
        fun onCardException(exception: CardServiceException)
        fun onGeneralException(exception: Exception?)
    }

    companion object {

        private val TAG = NFCDocumentTag::class.java.simpleName

        init {
            Security.insertProviderAt(org.spongycastle.jce.provider.BouncyCastleProvider(), 1)
        }

        private val EMPTY_TRIED_BAC_ENTRY_LIST = emptyList<Any>()
        private val EMPTY_CERTIFICATE_CHAIN = emptyList<Any>()
    }
}